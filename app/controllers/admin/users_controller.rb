class Admin::UsersController < AdminAreaController

  def index
    @users = User.find :all
    @user = User.new(params[:user])
    
    if request.post? && @user.save
      redirect_to :action => 'index'
    end
  end

  def edit
    @user = User.find(params[:id])
    if @user.login == 'Public'
      @user.attributes = params[:user]
      @user.login = 'Public'
    else
      @user.attributes = params[:user]
    end
    if request.post? && @user.save
      redirect_to :action => 'index'
    end
  end
  
  def delete
    #if request.post?
      user = User.find(params[:id])
      if user.login == 'Public'
        flash[:message] = 'You cannot delete the Public user placeholder'
      else
        user.destroy
      end
      redirect_to :action => 'index'
    #end
  end
end
