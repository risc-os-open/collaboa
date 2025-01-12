class MilestonesController < ApplicationController
  model :milestone, :ticket
  before_filter :login_required

  def index
    @milestones = Milestone.find_all("completed = 0")
  end
  
  def show
    @milestone = Milestone.find(params[:id])
  end
  
  def authorize?(user)
    user.view_milestones?
  end
    
end
