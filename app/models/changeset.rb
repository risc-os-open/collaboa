class Changeset < ApplicationRecord
  has_many :changes, dependent: :destroy

  validates_uniqueness_of :revision

  # Returns an array of "normalized" hashes, useful for mixing display of search
  # result from other resources (token finder code based on things found in Typo)
  #
  def self.search(query)
    if query.to_s.strip.present?
      tokens   = query.split.collect {|c| "%#{c.downcase}%"}
      findings = self.order('created_at DESC')

      tokens.each do | token |
        safe_token = ActiveRecord::Base.sanitize_sql_like(token)
        wildcard   = "%#{safe_token}%"
        findings   = findings.where('log ILIKE ?', wildcard)
      end

      findings.to_a.map do |f|
        {
          title:   "Changeset ##{f.revision}",
          content: f.log,
          link:    { controller: '/repository', action: 'show_changeset', revision: f.revision }
        }
      end
    else
      []
    end
  end

  # Syncronizes the database tables as needed with the repos
  # This method should be called from a before filter preferably
  # so that we always are in sync with the repos
  def self.sync_changesets
    begin
      Changeset.transaction do
        last_stored = Changeset.order('revision DESC').first

        if last_stored.nil?
          youngest_stored = 0
        else
          youngest_stored = last_stored.revision
        end

        youngest_rev = Repository.get_youngest_rev

        revs_to_sync = ((youngest_stored + 1)..youngest_rev).to_a
        revs_to_sync.each do |rev|
          revision = Repository.get_changeset(rev)

          cs = Changeset.new(
            revision:   rev,
            author:     revision.author,
            log:        revision.log_message,
            revised_at: revision.date
          )

          revision.copied_nodes.each do |path|
            cs.changes << Change.new(
              revision:      rev,
              name:          'CP',
              path:          path[0],
              from_path:     path[1],
              from_revision: path[2]
            )
          end

          revision.moved_nodes.each do |path|
            cs.changes << Change.new(
              revision:      rev,
              name:          'MV',
              path:          path[0],
              from_path:     path[1],
              from_revision: path[2]
            )
          end

          revision.added_nodes.each do |path|
            cs.changes << Change.new(revision: rev, name: 'A', path: path)
          end

          revision.deleted_nodes.each do |path|
            cs.changes << Change.new(revision: rev, name: 'D', path: path)
          end

          revision.updated_nodes.each do |path|
            cs.changes << Change.new(revision: rev, name: 'M', path: path)
          end

          cs.save!
          Rails.logger.info "* Synced changeset #{rev}"
        end if youngest_stored < youngest_rev
      end # end transaction
    rescue ActiveRecord::RecordInvalid
      # just silently ignore it and log it, we only have this one validation for now
      Rails.logger.error "Revision already exists"
    end
  end

end
