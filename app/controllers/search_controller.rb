class SearchController < ApplicationController
  before_action :login_required

  def index
    @found_items = []
    if params[:q]
      @found_items << Ticket.search(params[:q])
      @found_items << TicketChange.search(params[:q])
      Rails.logger.debug params[:changesets]
      if current_user.view_changesets? && params[:changesets]
        @found_items << Changeset.search(params[:q])
      end
      @found_items
    end
  end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    def authorize?(user)
      user.view_tickets?
    end

end
