class AdminAreaController < ApplicationController
  before_filter :login_required
  
  def authorize?(user)
    user.admin?
  end  
end