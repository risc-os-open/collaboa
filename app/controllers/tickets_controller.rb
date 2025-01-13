class TicketsController < ApplicationController
  include SortHelper
  before_action :login_required, :set_ivars_for_view

  # Beyond Collboa's built in login stuff, account management for guests
  # done via Hub. Normally if you can read a ticket you can comment on it;
  # we want to limit that to prevent spam.
  #
  HUBSSOLIB_PERMISSIONS = HubSsoLib::Permissions.new({
    :comment => [ :admin, :webmaster, :privileged, :normal ],
    :new     => [ :admin, :webmaster, :privileged, :normal ],
  })

  def self.hubssolib_permissions
    HUBSSOLIB_PERMISSIONS
  end

  # Redirect to a "default" filter once we've added, so we can save filters.
  #
  def index
    redirect_to action: 'filter', status: 1 # Not HTTP status! Yields "...?status=1"
  end

  def filter
    sort_init('created_at', 'desc')
    sort_update()

    Rails.logger.info "Sort_clause: #{sort_clause}"
    @tickets = Ticket.find_by_filter(params, sort_clause)

    render action: 'index'
  end

  def show
    begin
      @ticket = Ticket.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render text: "Unknown ticket number" and return
    end
  end

  def new
    @milestones = @milestones.where(completed: 0)
    @ticket     = Ticket.new

    @ticket.author ||= hubssolib_unique_name()
  end

  def create
    self.new()

    ticket_author_in_params = params[:ticket]&.delete(:author)
    @ticket                 = Ticket.new(self.safe_ticket_params())
    @ticket.author_host     = request.remote_ip
    @ticket.status          = Status.find_by_name('Open')

    if hubssolib_privileged? && ticket_author_in_params.present?
      @ticket.author = ticket_author_in_params
    else
      @ticket.author = hubssolib_unique_name()
    end

    success = @ticket.save()
    redirect_to(@ticket) if success
  end

  def comment
    @milestones = Milestone.all
    @parts      = Part.all.order('name ASC')
    @severities = Severity.all.order('position DESC')
    @status     = Status.all
    @releases   = Release.all

    begin
      @ticket = Ticket.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render text: "Unknown ticket number" and return
    end

    @ticket.assign_attributes(self.safe_ticket_params())

    change_author_in_params = params[:change]&.delete(:author)
    @change                 = TicketChange.new(self.safe_change_params())
    @change.ticket          = @ticket

    if hubssolib_privileged? && change_author_in_params.present?
      @change.author = params[:change][:author]
    else
      @change.author = hubssolib_unique_name()
    end

    if request.post?
      success = @ticket.save() # Also saves associated TicketChange within a transaction
      redirect_to(@ticket) if success
    end
  end

  def attachment
    @change = TicketChange.find(params[:id])
    unless @change.has_attachment?
      redirect_to(action: 'show', id: @change.ticket_id)
    else
      begin
        fullpath = @change.attachment_fsname
        send_file(fullpath, filename: @change.attachment, type: @change.content_type, disposition: 'inline')
      rescue
        render text: "Could not find attachment"
      end
    end
  end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    def set_ivars_for_view
      @milestones = Milestone.all
      @parts      = Part.all.order('name ASC')
      @severities = Severity.all.order('position DESC')
      @status     = Status.all
      @releases   = Release.all
    end

    def authorize?(user)
      if action_name == 'new'
        user.create_tickets?
      else
        user.view_tickets?
      end
    end

    def safe_ticket_params
      params.require(:ticket).permit([])
    end

    def safe_change_params
      params.require(:change).permit([])
    end

end
