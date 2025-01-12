class TicketChange < ActiveRecord::Base
  belongs_to :ticket
  serialize :log

  def each_log
    return unless self.log
    self.log.each do |name, (old_value, new_value)|
      yield [name, old_value, new_value]
    end
  end

  def empty?
    return false if self.comment && !self.comment.empty?
    return false if self.log && !self.log.empty?
    return false if self.attachment && !self.attachment.empty?
    true
  end

  # TODO: flesh out
  def attach(attachment)
    unless attachment.blank?
      self.attachment = base_part_of(attachment.original_filename)
      self.content_type = attachment.content_type.strip
      self.attachment_fsname = dump_filename
      filename = dump_filename
      attachment.rewind
      File.open(filename, "wb") do |f|
        f.write(attachment.read)
      end
    end
  end

  def dump_filename
    File.expand_path(File.join(ATTACHMENTS_PATH, "#{self.id}-#{self.attachment}"))
  end

  def has_attachment?
    self.attachment && !self.attachment.empty?
  end

  class << self
    # Returns am array of "normalized" hashes, useful for mixing display of search result from
    # other resources (token finder code based on things found in Typo)
    def search(query)
      if !query.to_s.strip.empty?
        tokens = query.split.collect {|c| "%#{c.downcase}%"}
        findings = find( :all,
                      :conditions => [(["(LOWER(comment) LIKE ?)"] * tokens.size).join(" AND "),
                                      *tokens.collect { |token| [token] }.flatten],
                      :order => 'created_at DESC')
        findings.collect do |f|
          {
            :title => "Ticket ##{f.ticket_id} comment by #{f.author}",
            :content => f.comment,
            :link => { :controller => '/tickets', :action => 'show', :id => f.ticket_id },
            :status => (f.ticket.status.name rescue 'Unknown')
          }
        end
      else
        []
      end
    end
  end

  protected
    validates_presence_of :author

  private
    def base_part_of(filename)
      filename = File.basename(filename.strip)
      # remove leading period, whitespace and \ / : * ? " ' < > |
      filename = filename.gsub(%r{^\.|[\s/\\\*\:\?'"<>\|]}, '_')
    end

end
