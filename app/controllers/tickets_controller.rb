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
    redirect_to(url_for(action: 'filter', status: 1)) # Not HTTP status! Yields "...?status=1"
  end

  def filter
    sort_init('created_at', 'desc')
    sort_update()

    tickets = Ticket.find_by_filter(params, sort_clause())

    @ticket_pages, @tickets = pagy_with_params(
      scope:         tickets,
      default_limit: 50
    )

    render action: 'index'
  end

  def show
    begin
      @ticket = Ticket.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Unknown ticket number"
      redirect_to(root_path())
    end
  end

  def new
    @milestones = @milestones.where(completed: 0)
    @ticket     = Ticket.new
  end

  def create
    self.new()

    ticket_author_in_params = params[:ticket]&.delete(:author)
    @ticket                 = Ticket.new(self.safe_ticket_params())
    @ticket.author          = hubssolib_unique_name()
    @ticket.author_email    = hubssolib_current_user()&.user_email
    @ticket.author_host     = request.remote_ip
    @ticket.status          = Status.find_by_name('Open')

    success = @ticket.save()
    success ? redirect_to(@ticket) : render(action: 'new')
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
      render plain: "Unknown ticket number" and return
    end

    if request.post?
      @ticket.assign_attributes(self.safe_comment_params())
      @change = @ticket.ticket_changes.last
    else
      @change = @ticket.ticket_changes.build
    end

    @change.author       = hubssolib_unique_name()
    @change.author_email = hubssolib_current_user()&.user_email

    if request.post?
      success = @ticket.save_with_new_ticket_change(
        @change,
        params.dig(:ticket, :ticket_changes_attributes, :'0', :attachment)
      )

      redirect_to(@ticket) if success
    end
  end

  def attachment
    change = TicketChange.find(params[:id])
    unless change.has_attachment?
      redirect_to(action: 'show', id: change.ticket_id)
    else
      begin
        fullpath = change.attachment_fsname
        send_file(fullpath, filename: change.attachment, type: change.content_type, disposition: 'inline')
      rescue
        render plain: "Could not find attachment"
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
      params.require(:ticket).permit(
        :summary,
        :content,
        :status_id,
        :severity_id,
        :part_id,
        :release_id,
        :milestone_id
      )
    end

    def safe_comment_params
      params.require(:ticket).permit(
        :summary,
        :status_id,
        :severity_id,
        :part_id,
        :release_id,
        :milestone_id,
        ticket_changes_attributes: [
          :comment,
          :attachment
        ]
      )
    end

end
