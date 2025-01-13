class AdminAreaController < ApplicationController
  before_action :login_required
  
  def authorize?(user)
    user.admin?
  end  
end