class Ticket < ApplicationRecord
  belongs_to  :milestone
  belongs_to  :part
  belongs_to  :severity
  belongs_to  :status
  belongs_to  :release
  has_many    :ticket_changes, :order => 'created_at', :dependent => true

  attr_protected :author

  def before_save
    self.status ||= Status.find(1)
    self.severity ||= Severity.find(1)
  end

  # Overriding save to allow for creating the TicketChange#log if we're
  # editing a ticket
  # Returns the normal save if +params+ is nil or self.new_record=true
  def save(params=nil)
    return super() if self.new_record? || params.nil?
    self.attributes = params[:ticket]
    return false unless super()

    change = TicketChange.new(params[:change])

    self.ticket_changes << change
    change.log = @log
    change.attach(params[:change][:attachment]) unless params[:change][:attachment].blank?

    if change.empty?
      self.errors.add_to_base 'No changes has been made'
      self.ticket_changes.delete(change)
      change.destroy
      return nil
    else
      change.save
    end
  end

  def next
    Ticket.find(:first, :conditions => ['id > ?', id], :order =>'id ASC')
  end

  def previous
    Ticket.find(:first, :conditions => ['id < ?', id], :order => 'id desc')
  end

  class << self
    # Returns am array of "normalized" hashes, useful for mixing display of search result from
    # other resources (token finder code based on things found in Typo)
    def search(query)
      if !query.to_s.strip.empty?
        tokens = query.split.collect {|c| "%#{c.downcase}%"}
        findings = find( :all,
                      :conditions => [(["(LOWER(summary) LIKE ? OR LOWER(content) LIKE ?)"] * tokens.size).join(" AND "),
                                      *tokens.collect { |token| [token] * 2 }.flatten],
                      :order => 'created_at DESC')
        findings.collect do |f|
          {
            :title => f.summary,
            :content => f.content,
            :link => { :controller => '/tickets', :action => 'show', :id => f.id },
            :status => (f.status.name rescue 'Unknown')
          }
        end
      else
        []
      end
    end

    # Find a bunch of Tickets from a hash of SQL-like fragments. Silently discards
    # everything we don't want. Accepts +order_by+, +direction+ and +limit+ to limit/order
    # the results (eg from a table sort etc)
    def find_by_filter(params = nil, order_by = 'created_at desc', limit = '')
      filters = []
      good_fields = %w{milestone part severity release status}
      params.each do |field, value|
        operator = ' = '
        if good_fields.include? field
          if field == 'status' && (value.to_i) == -1
            operator = ' >= '
            value = 2
          end
          filters << "tickets.#{field}_id" + operator + sanitize(value.to_i)
        end
      end
      filters = 'WHERE ' + filters.join(' AND ') unless filters.empty?

      #order_by = 'created_at' unless %w{created_at name id}.include? order_by
      direction = 'DESC' unless %w{ASC DESC}.include? direction

      find_by_sql %{SELECT tickets.*,
                            status.name AS status_name,
                            severities.name AS severity_name,
                            parts.name AS part_name,
                            milestones.name AS milestone_name,
                            releases.name AS release_name
                    FROM tickets
                    LEFT OUTER JOIN severities ON severities.id = tickets.severity_id
                    LEFT OUTER JOIN status ON status.id = tickets.status_id
                    LEFT OUTER JOIN parts ON parts.id = tickets.part_id
                    LEFT OUTER JOIN milestones ON milestones.id = tickets.milestone_id
                    LEFT OUTER JOIN releases ON releases.id = tickets.release_id
                    #{filters.to_s unless filters.empty?}
                    ORDER BY tickets.#{order_by} }
    end
  end

  protected
    validates_presence_of :author, :summary, :content

    LOG_MAP = {
      #'assigned_user_id' => ['Assigned', 'Unspecified', lambda{|v| User.find(v).username if v > 0}],
      'part_id' => ['Part', 'Unspecified', lambda{|v| Part.find(v).name if v > 0}],
      'release_id' => ['Release', 'Unspecified', lambda{|v| Release.find(v).name if v > 0}],
      'severity_id' => ['Severity', nil, lambda{|v| Severity.find(v).name if v > 0}],
      'status_id' => ['Status', nil, lambda{|v| Status.find(v).name if v > 0}],
      'milestone_id' => ['Milestone', 'Unspecified', lambda{|v| Milestone.find(v).name if v > 0}],
      'summary' => ['Summary', nil, lambda{|v| v unless v.empty?}],
    }

    # This cool write_attribute override is courtesy of Kent Sibilev
    def write_attribute(name, value)
      @log ||= {}

      if converter = LOG_MAP[name]
        old_value = read_attribute(name)

        column = column_for_attribute(name)
        if column
          value = column.type_cast(value) rescue value
        end

        loader = lambda{ |v|
          result = converter[2][v] if v
          result = converter[1] unless result
          result
        }

        if old_value != value
          @log[converter[0]] = [loader[old_value], loader[value]]
        end
      end

      super
    end
end
