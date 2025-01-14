class TicketChange < ApplicationRecord
  belongs_to :ticket
  serialize :log, coder: YAML, type: Hash

  validates_presence_of :author

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
    self.attachment && self.attachment.present?
  end

  # Returns an array of "normalized" hashes, useful for mixing display of search
  # result from other resources (token finder code based on things found in Typo)
  #
  def self.search(query)
    if query.to_s.strip.present?
      tokens   = query.split
      findings = self.order('created_at DESC')

      tokens.each do | token |
        safe_token = ActiveRecord::Base.sanitize_sql_like(token)
        wildcard   = "%#{safe_token}%"
        findings   = findings.where('comment ILIKE ?', wildcard)
      end

      findings.includes(ticket: :status).to_a.map do |f|
        {
          title:   "Ticket ##{f.ticket_id} comment by #{f.author}",
          content: f.comment,
          link:    { controller: '/tickets', action: 'show', id: f.ticket_id },
          status:  (f.ticket.status.name rescue 'Unknown')
        }
      end
    else
      []
    end
  end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    def base_part_of(filename)
      filename = File.basename(filename.strip)
      # remove leading period, whitespace and \ / : * ? " ' < > |
      filename = filename.gsub(%r{^\.|[\s/\\\*\:\?'"<>\|]}, '_')
    end

end
