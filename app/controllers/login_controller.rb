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

    if user = User.authenticate(params.dig(:user, :login), params.dig(:user, :password))
      # Reset the session properly to prevent a possible session fixation attack
      return_to = session[:return_to]
      self.reset_session()

      session[:user_id  ] = user.id
      session[:return_to] = return_to if return_to.present?

      flash[:notice] = 'Login successful'
      redirect_back_or_default(controller: 'admin', action: 'index') # See LoginSystem
    else
      @login = params.dig(:user, :login)
      flash[:error] = 'Login unsuccessful'
    end
  end

  # GET-only
  #
  def logout
    session[:user_id] = nil
    @current_user = User.find_by_login 'Public'
  end

end
