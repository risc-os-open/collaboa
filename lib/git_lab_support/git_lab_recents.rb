class GitLabSupport::GitLabRecents
  include Singleton

  # ============================================================================
  # PRIVATE CLASS METHODS
  # ============================================================================
  #
  def self.retrieve_latest
    self.instance.retrieve_latest
  end

  # ============================================================================
  # PUBLIC SINGLETON INSTANCE METHODS
  # ============================================================================
  #
  def retrieve_latest
    log "GitLabSupport::GitLabRecents#retrieve_latest: Running"

    client = GitLabSupport::GitLabApiClient.new( per_page: GitLabSupport::EVENTS_TO_INCLUDE )
    users  = JSON.parse( File.read( GitLabSupport::USERS_INCLUDED_PATH ) ) rescue []
    old    = Time.parse( '1970-01-01T00:00:00Z' )

    # Get a list of all users, so we can get events for each. There are
    # far fewer users than projects, so this is the best approach we have.
    # For each page of users, get up to "EVENTS_TO_INCLUDE" events using
    # threads for concurrent API requests.
    #
    if users.empty?
      users = client.paginate( :users ) do | users_page |
        puts users_page.inspect
        raise "Above was probably a 403, given no API auth. Configure users via #{GitLabSupport::USERS_INCLUDED_PATH.to_s.inspect} instead."
      end
    end

    events = []
    opts   =
    {
      active:   true,
      order_by: 'id',
      sort:     'asc'
    }

    log "GitLabSupport::GitLabRecents#retrieve_latest: Enumerating..."

    threads = []
    mutex   = Mutex.new

    # This gets messy as we're working across users and projects, so if we just
    # said "max 'N' event overall" then we'd have a race condition over which
    # user had that many events read out.
    #
    # Instead, we apply that same limit to *every* user, then take the sorted
    # (by event time) result and chop it to that same limit. It's inefficient
    # but works pretty well.
    #
    # There's an exception made for seen-in-wild cases where the iterator for a
    # user might keep paging through a very lage number of API calls, because
    # that user has many events on things we don't output - e.g. for work in a
    # personal namespace, rather than in INTERESTING_NAMESPACES. To avoid very
    # long delays to completion, we limit the number of overall events read,
    # regardless of how many were kept for that user, to twice the per user
    # limit.
    #
    users.each_slice(2) do | pair |
      user_id   = pair.first
      user_name = pair.last

      log "GitLabSupport::GitLabRecents#retrieve_latest: User #{ user_id } / #{ user_name }"

      threads << Thread.new do
        user_events       = []
        per_page          = 50
        total_events_read = 0

        # The GitLab event API is remarkably weak, including only having vague
        # filtering support for a very limited set of things and, within that,
        # only supporting one filter at a time. We cannot filter on, say, a
        # collection of action names.
        #
        # https://docs.gitlab.com/ee/api/events.html
        #
        # Instead, we're forced to enumerate everything and filter the result
        # on the client side.
        #
        client.paginate( :user_events, user_id, per_page: per_page ) do | user_events_page |

          # Warm up the project cache by querying all projects for this
          # batch in parallel. It's a lot faster than in series.
          #
          project_reader_threads = []
          user_events_page.each do | event |
            project_reader_threads << Thread.new do
              client.project( event[ 'project_id' ] )
            end
          end

          project_reader_threads.map( &:join )

          total_events_read += per_page

          # Select items that match our client-side filtering criteria.
          #
          user_events_page.select! do | event |
            GitLabSupport::INTERESTING_ACTION_NAMES.include?( event[ 'action_name' ] ) &&
            GitLabSupport::INTERESTING_TARGET_TYPES.include?( event[ 'target_type' ] ) &&
            event.dig( 'push_data', 'ref_type' ) != 'tag'                              &&
            include_project?( client.project( event[ 'project_id' ] ) )
          end

          log "GitLabSupport::GitLabRecents#retrieve_latest: User #{ user_id } / #{ user_name }: Keeping #{ user_events_page.count } event(s)"

          # Now make parallel API calls to get commit details, since for push
          # events, at least, the event's author information isn't helpful.
          #
          commit_reader_threads = []

          user_events_page.each do | event |
            project_id = event[ 'project_id' ]
            sha        = event.dig( 'push_data', 'commit_to' )

            if project_id.present? && sha.present?
              commit_reader_threads << Thread.new do
                commit = client.commit( project_id, sha )
                mutex.synchronize() { event[ 'push_data' ][ 'commit' ] = commit }
              end
            end
          end

          commit_reader_threads.map( &:join )

          # For the things we're keeping, replace the project ID field with
          # full project details.
          #
          user_events_page.each do | event |
            event[ 'project' ] = client.project( event.delete( 'project_id' ) )
          end

          user_events += user_events_page

          break if (
            user_events.size  >= GitLabSupport::EVENTS_TO_INCLUDE ||
            total_events_read >= GitLabSupport::EVENTS_TO_INCLUDE * 3
          )
        end

        mutex.synchronize() { events += user_events }
      end
    end

    threads.map( & :join )

    # Sort by event date-time descending then take only the number of items
    # we want from the result.

    def event_date( event )
      event.dig( 'push_data', 'commit', 'committed_date' ) || event.dig( 'push_data', 'commit', 'created_at' ) || event[ 'created_at' ]
    end

    events.sort! do | x, y |
      tx = Time.parse( event_date( x ) ) rescue old
      ty = Time.parse( event_date( y ) ) rescue old
      ty <=> tx
    end

    events = events.take( GitLabSupport::EVENTS_TO_INCLUDE )

    # Now process the event information to minimal JSON data.

    log "GitLabSupport::GitLabRecents#retrieve_latest: ...done"
    log "GitLabSupport::GitLabRecents#retrieve_latest: Processing event data to minimal JSON file..."

    json = []

    events.each do | event |
      project = event[ 'project' ]

      # Figure out basic event data

puts "****** " + project.inspect
puts "====== " + event.except('project').inspect

      date         = event_date( event )
      target       = event[ 'target_title' ]
      target       = event.dig( 'push_data', 'ref' ) if target.blank?
      author       = event.dig( 'push_data', 'commit', 'author_name' ) || event.dig( 'author', 'name' ) || '(Unknown author)'
      details      = event.dig( 'push_data', 'commit', 'message'     ) || event.dig( 'note',   'body' ) || ''
      action       = event[ 'action_name' ] || 'did something'
      project_path = project[ 'path_with_namespace' ]
      project_name = project[ 'name' ] || '(unknown project)'

      next if (Time.parse( date ).year rescue 1970) < 2006

      # Work out more detailed information (by API data observation)

      type            = nil
      id              = nil
      target_prefix = ''

      if event[ 'note' ].present?
        type = event.dig( 'note', 'noteable_type' )
        id   = event.dig( 'note', 'noteable_iid'  )
      elsif event[ 'push_data' ].present?
        type = event.dig( 'push_data', 'ref_type' )
        id   = event.dig( 'push_data', 'ref'      )
      else
        type = event[ 'target_type' ]
        id   = event[ 'target_iid'  ]
      end

      target_prefix = type.underscore.humanize.downcase rescue nil
      type            = 'commit' if type == 'branch'

      # Generate links, if we can

      type_url    = nil
      commit_url  = nil
      project_url = "https://gitlab.riscosopen.org/#{ project_path }"

      unless type.blank? || id.blank?
        type_path = type.pluralize.underscore
        type_url  = "https://gitlab.riscosopen.org/#{ project_path }/#{ type_path }/#{ id }"
      end

      sha   = event.dig( 'push_data', 'commit_to'    )
      title = event.dig( 'push_data', 'commit_title' )

      unless sha.blank? || title.blank?
        commit_url = "https://gitlab.riscosopen.org/#{ project_path }/commit/#{ sha }"
      end

      summary = title

      if summary.blank?
        summary = details.split( "\n" ).first || ''
        summary = summary[0..50] + '...' if (summary.length > 50)
      end

      # # If we were to (say) assemble the data to print out...
      #
      # line =
      # [
      #   "<strong>#{ h( author ) }</strong>",
      #   commit_url.nil? ? action : "<a href=\"#{ h( commit_url ) }\">#{ h( action ) }</a>",
      #   h( target_prefix )
      # ]
      #
      # unless target.blank?
      #   line << ( type_url.nil? ? target : "<a href=\"#{ h( type_url ) }\">#{ h( target ) }</a>" )
      #   line << "in"
      # end
      #
      # line << "<a href=\"#{ h( project_url ) }\">#{ h( project_name ) }</a>"
      # line << "&ndash; <span class=\"summary\">#{ h( summary ) }</span>" unless summary.blank?
      # line << "<span class=\"date\">(#{ date })</span>"
      #
      # puts "  <li>" + line.compact.join( ' ' )

      json << {
        author:        author,
        action:        action,
        action_url:    clean_url( commit_url ),
        target_prefix: target_prefix,
        target:        target,
        target_url:    clean_url( type_url ),
        summary:       summary,
        details:       details,
        project:       project_name,
        project_url:   clean_url( project_url ),
        date:          date
      }
    end

    log "GitLabSupport::GitLabRecents#retrieve_latest: Writing #{GitLabSupport::JSON_OUTPUT_PATH}..."

    File.write( GitLabSupport::JSON_OUTPUT_PATH, JSON.fast_generate( json ) )

    log "GitLabSupport::GitLabRecents#retrieve_latest: ...done"
    log "GitLabSupport::GitLabRecents#retrieve_latest: Finished"
  end

  # ============================================================================
  # PRIVATE SINGLETON INSTANCE METHODS
  # ============================================================================
  #
  private

    def log(str)
      if (defined? Rails) && Rails.respond_to?(:logger)
        Rails.logger.debug(str)
      else
        puts(str)
      end
    end

    def clean_url( untrustworthy_url )
      URI.parse( untrustworthy_url ).to_s rescue nil
    end

    # The V4 API is documented as having a 'visibility' field of 'public' for
    # public projects. This was present during initial development. At some
    # later point, GitLab stopped sending this field. Documentation calls it
    # "optional", but doesn't say what omission means.
    #
    # Since we use unauthenticated access to the GitLab API, we assume that the
    # behaviour above arises because a project obtained over API *must* be
    # public by definition (this is a no-auth, public-only API call).
    #
    # THIS IS OBVIOUSLY DANGEROUS, but the API response leaves us no choice.
    #
    def include_project?( project )
      return (
        (
          project.key?( 'visibility' ) == false ||
          project[ 'visibility' ] == 'public'
        ) &&
        GitLabSupport::INTERESTING_NAMESPACES.any? { | namespace_prefix |
          project[ 'path_with_namespace' ].start_with?( namespace_prefix )
        }
      )
    end

end
