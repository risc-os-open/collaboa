class TicketsController < ApplicationController
  helper :sort
  include SortHelper
  before_filter :login_required

  # Beyond Collboa's built in login stuff, account management for guests
  # done via Hub. Normally if you can read a ticket you can comment on it;
  # we want to limit that to prevent spam.

  @@hubssolib_permissions = HubSsoLib::Permissions.new({
                              :comment => [ :admin, :webmaster, :privileged, :normal ],
                              :new     => [ :admin, :webmaster, :privileged, :normal ],
                            })

  def TicketsController.hubssolib_permissions
    @@hubssolib_permissions
  end

  def index
    # Redirect to a "default" filter once we've added so we can save filters
    redirect_to :action => 'filter', :status => 1
  end

  def filter
    sort_init('created_at', 'desc')
    sort_update

    @milestones = Milestone.find(:all)
    @parts = Part.find(:all, :order => 'name ASC')
    @severities = Severity.find(:all, :order => 'position DESC')
    @status = Status.find(:all)
    logger.info "sort_clause: #{sort_clause}"
    @tickets = Ticket.find_by_filter(params, sort_clause)
    render :action => 'index'
  end

  def show
    @milestones = Milestone.find(:all)
    @parts = Part.find(:all, :order => 'name ASC')
    @severities = Severity.find(:all, :order => 'position DESC')
    @releases = Release.find(:all)
    @status = Status.find(:all)

    begin
      @ticket = Ticket.find(params[:id], :include => [ :severity, :part, :status, :milestone ])
    rescue ActiveRecord::RecordNotFound
      render :text => "Unknown ticket number" and return
    end
  end

  def comment
    @milestones = Milestone.find(:all)
    @parts = Part.find(:all, :order => 'name ASC')
    @severities = Severity.find(:all, :order => 'position DESC')
    @releases = Release.find(:all)
    @status = Status.find(:all)

    begin
      @ticket = Ticket.find(params[:id], :include => [ :severity, :part, :status, :milestone ])
    rescue ActiveRecord::RecordNotFound
      render :text => "Unknown ticket number" and return
    end

    @change = TicketChange.new
    @change.author = hubssolib_unique_name

    @change.attributes = params[:change]
    @ticket.attributes = params[:ticket]

    if request.post? && (@change.valid? && @ticket.valid?)
      @change.author = params[:change][:author]
      if @ticket.save(params)
        redirect_to :action => 'show', :id => @ticket.id
      end
    end
  end

  def attachment
    @change = TicketChange.find(params[:id])
    unless @change.has_attachment?
      redirect_to :action => 'show', :id => @change.ticket_id
    else
      begin
        fullpath = @change.attachment_fsname
        send_file(fullpath, :filename => @change.attachment,:type => @change.content_type, :disposition => 'inline')
      rescue
        render :text => "Could not find an attachment for this id"
      end
    end
  end

  def new
    @milestones = Milestone.find(:all, :conditions => "completed = 0")
    @parts = Part.find(:all, :order => 'name ASC')
    @severities = Severity.find(:all, :order => 'position DESC')
    @releases = Release.find(:all)

    @ticket = Ticket.new
    @ticket.author ||= hubssolib_unique_name

    if request.post?
      @ticket = Ticket.new(params[:ticket])
      @ticket.author = params[:ticket][:author]
      @ticket.author_host = request.remote_ip
      @ticket.status = Status.find_by_name('Open')

      if @ticket.save
        redirect_to :action => 'show', :id => @ticket.id
      end
    end
  end

  private
    def authorize?(user)
      if action_name == 'new'
        user.create_tickets?
      else
        user.view_tickets?
      end
    end

end
