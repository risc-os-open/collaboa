class SearchController < ApplicationController
  before_filter :login_required

  def index
    @found_items = []
    if params[:q]
      @found_items << Ticket.search(params[:q])
      @found_items << TicketChange.search(params[:q])
      logger.debug params[:changesets]
      if current_user.view_changesets? && params[:changesets]
        @found_items << Changeset.search(params[:q])
      end
      @found_items
    end
  end
  
  private
    def authorize?(user)
      user.view_tickets?
    end
  
end
