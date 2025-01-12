class LoginController < ApplicationController
  def index
    redirect_to :action => 'login'
  end

  # Insist on being a Hub admin before allowing further access

  @@hubssolib_permissions = HubSsoLib::Permissions.new({
                              :login => [ :admin, :webmaster, :privileged, :normal ]
                            })

  def LoginController.hubssolib_permissions
    @@hubssolib_permissions
  end

  def login
    case request.method
      when :post
        if user = User.authenticate(params[:user_login], params[:user_password])
          # Reset the session properly to prevent a possible session fixation attack
          return_to = session[:return_to]
          reset_session
          session[:user_id] = user.id
          session[:return_to] = return_to if return_to

          flash[:notice]  = "Login successful"
          redirect_back_or_default :controller => 'admin', :action => 'index'
        else
          @login    = params[:user_login]
          @message  = "Login unsuccessful"
      end
    end
  end

  def logout
    session[:user_id] = nil
    @current_user = User.find_by_login 'Public'
  end

end
