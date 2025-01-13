class MilestonesController < ApplicationController
  before_action :login_required

  def index
    @milestones = Milestone.where(completed: 0)
  end

  def show
    @milestone = Milestone.find(params[:id])
  end

  def authorize?(user)
    user.view_milestones?
  end
end
