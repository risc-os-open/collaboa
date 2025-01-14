class Ticket < ApplicationRecord
  belongs_to :status
  belongs_to :severity
  belongs_to :part,      optional: true
  belongs_to :release,   optional: true
  belongs_to :milestone, optional: true

  has_many(
    :ticket_changes,
    -> { order('created_at ASC') },
    dependent: :destroy
  )

  accepts_nested_attributes_for(:ticket_changes, limit: 1)

  validates_presence_of :author, :summary, :content

  # These are both filter parameters passed in for use by ::find_by_filter and
  # association names in the belongs-to relationships declared earlier.
  #
  PERMITTED_FILTER_FIELDS = %w{milestone part severity release status}

  # See the custom override of #write_attribute for details.
  #
  LOG_MAP = {
    #'assigned_user_id' => ['Assigned', 'Unspecified', lambda{|v| User.find(v).username if v > 0}],
    'part_id'      => ['Part',      'Unspecified', lambda{|v|      Part.find(v).name if v.present?}],
    'release_id'   => ['Release',   'Unspecified', lambda{|v|   Release.find(v).name if v.present?}],
    'severity_id'  => ['Severity',  nil,           lambda{|v|  Severity.find(v).name if v.present?}],
    'status_id'    => ['Status',    nil,           lambda{|v|    Status.find(v).name if v.present?}],
    'milestone_id' => ['Milestone', 'Unspecified', lambda{|v| Milestone.find(v).name if v.present?}],
    'summary'      => ['Summary',   nil,           lambda{|v| v unless v.empty?}],
  }

  def before_save
    self.status   ||= Status.find(1)
    self.severity ||= Severity.find(1)
  end

  # A special case for saving a record with a new ticket change that will get
  # the log data and attachments handled on-the-fly herein.
  #
  # Pass a constructed Change via nested attribute assignment, along with the
  # params.dig(:ticket, :ticket_changes_attributes, :'0', :attachment) value
  # from the form submission, or equivalent.
  #
  # Returns the same as base #save - +true+ for success, +false+ for failure
  # (in which case, examine the object's ActiveRecord errors collection).
  #
  def save_with_new_ticket_change(change, attachment_param)
    success                         = false
    annotated_ticket_alteration_log = self.build_log()

    ActiveRecord::Base.transaction do
      if save() == true
        change.log = annotated_ticket_alteration_log
        change.attach(attachment_param) if attachment_param.present?

        if change.empty?
          self.errors.add :base, 'You must at least add a comment'
          raise ActiveRecord::Rollback
        else
          success = change.save()
        end
      end
    end

    return success
  end

  def next
    Ticket.order('id ASC').where('id > ?', id).first
  end

  def previous
    Ticket.order('id DESC').where('id < ?', id).first
  end


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
        findings   = findings.where('(summary ILIKE ? OR content ILIKE ?)', wildcard, wildcard)
      end

      findings.to_a.map do |f|
        {
          title:   f.summary,
          content: f.content,
          link:    { controller: '/tickets', action: 'show', id: f.id },
          status:  (f.status.name rescue 'Unknown')
        }
      end
    else
      []
    end
  end

  # Find a bunch of Tickets based on PERMITTED_FILTER_FIELDS name-value pairs,
  # where values are association IDs.
  #
  # All associations named in PERMITTED_FILTER_FIELDS will be eager-loaded in
  # the returned ActiveRecord::Relation result.
  #
  def self.find_by_filter(params, order_by = 'created_at DESC')
    scope = self
      .order(order_by)
      .includes(:ticket_changes, *PERMITTED_FILTER_FIELDS) # Eager-load all

    params.each do | field, value |
      next unless PERMITTED_FILTER_FIELDS.include?(field)

      if field == 'status' && (value.to_i) == -1
        scope = scope.where('"tickets"."status_id" >= 2')
      else
        scope = scope.where("\"tickets\".\"#{field}_id\" = ?", value.to_i)
      end
    end

    return scope
  end

  # ============================================================================
  # PROTECTED INSTANCE METHODS
  # ============================================================================
  #
  protected

    # Uses self.changes to build a log of alterations suitable for encoding
    # into a TicketChange 'log' field.
    #
    # Call for a 'dirty' record BEFORE saving.
    #
    def build_log
      log = {}

      self.changes.each do | attribute, old_new |
        converter = LOG_MAP[attribute]
        next if converter.nil?

        old_value = old_new.first
        new_value = old_new.last

        loader = lambda { |v|
          result = converter[2][v] if v
          result = converter[1] unless result
          result
        }

        log[converter[0]] = [loader[old_value], loader[new_value]]
      end

      return log
    end

end
