class Admin::UsersController < AdminAreaController

  def index
    @users = User.all
    @user  = User.new
  end

  def create
    @user   = User.new(self.safe_params())
    success = @user.save()

    redirect_to(action: 'index') if success
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user     = User.find(params[:id])
    is_public = (@user.login == 'Public')

    @user.assign_attributes(self.safe_params())
    @user.login = 'Public' if is_public

    success = @user.save

    redirect_to(action: 'index') if success
  end

  def destroy
    user = User.find_by_id(params[:id])

    if user&.login == 'Public'
      flash[:message] = 'You cannot delete the Public user placeholder'
    else
      user&.destroy!
    end

    redirect_to(action: 'index')
  end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    def safe_params
      params.require(:user).permit(
        :login,
        :password,
        :password_confirmation,
        :view_changesets,
        :view_code,
        :view_tickets,
        :view_milestones,
        :create_tickets,
        :admin
      )
    end

end
