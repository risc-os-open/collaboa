class LoginController < ApplicationController
  def index
    redirect_to :action => 'login'
  end

  # Insist on being a Hub admin before allowing further access
  #
  HUBSSOLIB_PERMISSIONS = HubSsoLib::Permissions.new({
    :login => [ :admin, :webmaster, :privileged, :normal ]
  })

  def self.hubssolib_permissions
    HUBSSOLIB_PERMISSIONS
  end

  def login
    render() and return unless request.post?

    if user = User.authenticate(params[:user_login], params[:user_password])
      # Reset the session properly to prevent a possible session fixation attack
      return_to = session[:return_to]
      self.reset_session()
      session[:user_id  ] = user.id
      session[:return_to] = return_to if return_to.present?

      flash[:notice] = "Login successful"
      redirect_to(admin_root_path())
    else
      @login   = params[:user_login]
      @message = 'Login unsuccessful'
    end
  end

  # GET-only
  #
  def logout
    session[:user_id] = nil
    @current_user = User.find_by_login 'Public'
  end

end
