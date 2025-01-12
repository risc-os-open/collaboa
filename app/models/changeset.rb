class Changeset < ApplicationRecord
  has_many :changes, :dependent => true
  
  validates_uniqueness_of :revision
  
  # Returns am array of "normalized" hashes, useful for mixing display of search result from
  # other resources (token finder code based on things found in Typo)
  def self.search(query)
    if !query.to_s.strip.empty?
      tokens = query.split.collect {|c| "%#{c.downcase}%"}
      findings = find( :all,
                    :conditions => [(["(LOWER(log) LIKE ?)"] * tokens.size).join(" AND "), 
                                    *tokens.collect { |token| [token] }.flatten],
                    :order => 'created_at DESC')
      findings.collect do |f| 
        { 
          :title => "Changeset ##{f.revision}", 
          :content => f.log, 
          :link => { :controller => '/repository', :action => 'show_changeset', :revision => f.revision } 
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
        last_stored = Changeset.find_first(nil, "revision DESC")
        if last_stored.nil?
          youngest_stored = 0
        else
          youngest_stored = last_stored.revision
        end
        youngest_rev = Repository.get_youngest_rev
        
        revs_to_sync = ((youngest_stored + 1)..youngest_rev).to_a
        revs_to_sync.each do |rev|
          revision = Repository.get_changeset(rev)

          cs = Changeset.new(:revision => rev, 
                                    :author => revision.author,
                                    :log => revision.log_message,
                                    :revised_at => revision.date)

          revision.copied_nodes.each do |path|
            cs.changes << Change.new(:revision => rev, :name => 'CP', 
                            :path => path[0], :from_path => path[1], 
                            :from_revision => path[2])
            #logger.info "  CP #{path[0]} (from #{path[1]}:#{path[2]})"
          end

          revision.moved_nodes.each do |path|
            cs.changes << Change.new(:revision => rev, :name => 'MV', 
                            :path => path[0], :from_path => path[1], 
                            :from_revision => path[2])
            #logger.info "  MV #{path[0]} (from #{path[1]}:#{path[2]})"
          end

          revision.added_nodes.each do |path|
            cs.changes << Change.new(:revision => rev, :name => 'A', :path => path)
            #logger.info "  A #{path}"                                             
          end                                                                      
                                                                               
          revision.deleted_nodes.each do |path|                                    
            cs.changes << Change.new(:revision => rev, :name => 'D', :path => path)
            #logger.info "  D #{path}"                                             
          end                                                                      
                                                                               
          revision.updated_nodes.each do |path|                                    
            cs.changes << Change.new(:revision => rev, :name => 'M', :path => path)
            #logger.info "  M #{path}"
          end
      
          cs.save!
      
          logger.info "* Synced changeset #{rev}"
        end if youngest_stored < youngest_rev
      end # end transaction
    rescue ActiveRecord::RecordInvalid => rie
      # just silently ignore it and log it, we only have this one validation for now
      #logger.error rie
      logger.error "Revision already exists"
    end
  end
  
end