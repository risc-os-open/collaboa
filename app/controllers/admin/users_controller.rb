class Admin::UsersController < AdminAreaController

  # This doubles up as an inline 'new' action, for convenience.
  #
  def index
    @users = User.order('login ASC')
    @user  = User.new
  end

  # Handles submissions from the inline index view form.
  #
  def create
    self.index() # Initialise ivars

    @user   = User.new(self.safe_params())
    success = @user.save()
    success ? redirect_to(action: 'index') : render(action: 'index')
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
    success ? redirect_to(action: 'index') : render(action: 'edit')
  end

  def destroy
    user = User.find(params[:id])

    if user.login == 'Public'
      flash[:error] = 'You cannot delete the Public user placeholder'
    else
      user.destroy!
      flash[:notice] = "User '#{user.login}' deleted"
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
