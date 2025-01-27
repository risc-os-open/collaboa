# There are doubtless already one or more SDKs in Ruby for this API, but the
# risk of abandonware is too great (given ROOL's history with Rails and gems!)
# and the task of calling the API far too simple to need to bother using any.
#
# This works with to-ROOL public data access API calls only; no auth needed.
#
class GitLabSupport::GitLabApiClient

  BASE_URL = "https://gitlab.riscosopen.org/api/v4/"

  # ============================================================================
  # PRIVATE ATTRIBUTES
  # ============================================================================
  #
  private

    attr_accessor  :projects_cache
    cattr_accessor :projects_wrapper_mutex

    self.projects_wrapper_mutex = Mutex.new

  # ============================================================================
  # PRIVATE ATTRIBUTES AND INSTANCE METHODS
  # ============================================================================
  #
  public

    attr_accessor :base_url
    attr_accessor :per_page

    def initialize( options )
      self.base_url = options[ :base_url ] || BASE_URL
      self.per_page = options[ :per_page ] || 20

      self.projects_cache = {}
          @projects_mutex = {}
    end

    # Paginate over a list based on some named method and arguments.
    #
    # +method+::  The name of the method to call, e.g. :projects.
    # +args+::    A list of zero or more arguments to pass to it.
    # +handler+:: A block invoked with each page of retrieved data.
    #
    # Examples:
    #
    #     # Get pages of project information, ultimately enumerating all of
    #     # the projects on the target server.
    #     #
    #     client.paginate( :projects ) do | projects_page |
    #       puts projects_page.inspect
    #     end
    #
    #     # Enumerate all commits for project ID 23.
    #     #
    #     client.paginate( :commits, 23 ) do | commits_page |
    #       puts commits_page.inspect
    #     end
    #
    def paginate( method, *args, &handler )
      page          = 1
      results_count = 0

      options = if ( args.last.is_a?( Hash ) )
        args.pop()
      else
        {}
      end

      args.push( options )

      loop do
        options[ :page ] = page
        page += 1

        results       = send( method, *args )
        results_count = results.size rescue 0

        yield( results )
        break if results_count < ( options[ :per_page ] || per_page )
      end
    end

    # ========================================================================
    # API methods which fetch lists. To be compatible with #paginate, all
    # parameters must be mandatory except the last one, which must be an
    # options hash passed to private method #get.
    # ========================================================================

    # Get a page of user data. Access token will require the 'sudo' flag.
    #
    # +options+:: Options hash; see GitLab API for details.
    #             https://docs.gitlab.com/ce/api/users.html#list-users
    #
    def users( options = {} )
      get( 'users', options )
    end

    # Get a page of project data.
    #
    # +options+:: Options hash; see GitLab API for details.
    #             https://docs.gitlab.com/ce/api/projects.html#list-all-projects
    #
    def projects( options = {} )
      get( 'projects', options )
    end

    # Get a page of commit data.
    #
    # +project_id+:: ID of project for which commit information is required.
    # +options+::    Options hash; see GitLab API for details.
    #                https://docs.gitlab.com/ce/api/commits.html#list-repository-commits
    #
    def commits( project_id, options = {} )
      get( "projects/#{ project_id }/repository/commits", options )
    end

    # Get details of a single commit.
    #
    # +project_id+:: ID of project for which commit information is required.
    # +sha+::        SHA of commit of interest.
    # +options+::    Options hash; see GitLab API for details.
    #                https://docs.gitlab.com/ce/api/commits.html#get-a-single-commit
    #
    def commit( project_id, sha, options = {} )
      get( "projects/#{ project_id }/repository/commits/#{ sha }", options )
    end

    # Get a page of merge requests for a particular project.
    #
    # +project_id+:: ID of project for which merge requests are required.
    # +options+::    Options hash; see GitLab API for details.
    #                https://docs.gitlab.com/ce/api/merge_requests.html#list-project-merge-requests
    #
    def merge_requests( project_id, options = {} )
      get( "projects/#{ project_id }/repository/merge_requests", options )
    end

    # Get a page of events for the given project.
    #
    # +project_id+:: ID of project for which events are required.
    # +options+::    Options hash; see GitLab API for details.
    #                https://docs.gitlab.com/ce/api/events.html#list-a-projects-visible-events
    #
    #
    def project_events( project_id, options = {} )
      get( "projects/#{ project_id }/events", options )
    end

    # Get a page of events for the given user. Access token will require
    # the 'sudo' flag.
    #
    # +user_id+:: ID of user for which events are required.
    # +options+:: Options hash; see GitLab API for details.
    #             https://docs.gitlab.com/ce/api/events.html#get-user-contribution-events
    #
    def user_events( user_id, options = {} )
      get( "users/#{ user_id }/events", options )
    end

    # Get information about a particular project, by ID. Caches the result,
    # unless asked to forcibly reload.
    #
    # +project_id+::   ID of project of interest.
    # +options+::      Options hash; see GitLab API for details.
    #                  https://docs.gitlab.com/ce/api/projects.html#get-single-project
    # +ignore_cache+:: If "true", ignore any cached value (default is "false").
    #
    def project( project_id, options = {}, ignore_cache = false )
      make_api_call = false

      # Need to synchronize overall data checks on the global mutex,
      # then have a per-project-ID mutex so that if several threads
      # try to near-simultaneously pull the *same* project ID, they
      # will wait on the mutex until the first one fetches it; but
      # several threads requesting *different* project IDs can still
      # run in parallel.

      self.class.projects_wrapper_mutex.synchronize do
        make_api_call = ignore_cache || ! @projects_mutex.has_key?( project_id )
        @projects_mutex[ project_id ] = Mutex.new if ( make_api_call )
      end

      @projects_mutex[ project_id ].synchronize do
        if ( make_api_call )
          projects_cache[ project_id ] = get( "projects/#{ project_id }", options )
        end

        return projects_cache[ project_id ]
      end
    end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    def get( endpoint, options )
      url = URI.parse( "#{ @base_url }/#{ endpoint }" )

      options[ :per_page ] ||= per_page

      options.each do | key, value |
        if value.is_a?( Date ) || value.is_a?( Time ) || value.is_a?( DateTime )
          options[ key ] = value.iso8601() rescue value
        end
      end

      url.query = URI.encode_www_form( options )

      http              = Net::HTTP.new( url.host, url.port )
      http.use_ssl      = true
      http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
      http.read_timeout = 5
      http.open_timeout = 5

      request = Net::HTTP::Get.new( url.request_uri )
      request[ 'Private-Token' ] = ENV[ 'GITLAB_ACCESS_TOKEN' ]
      response = http.request( request )

      return begin
        JSON.parse( response.body )
      rescue Exception => e
        { "error" => e.message }
      end
    end
end
