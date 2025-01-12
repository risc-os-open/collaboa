require_dependency "login_system"

class ApplicationController < ActionController::Base

  # Hub single sign-on support.

  require 'hub_sso_lib'
  include HubSsoLib::Core
  before_filter :hubssolib_beforehand
  after_filter :hubssolib_afterwards

  # Now Collaboa's own administrative login system.

  include LoginSystem

  before_filter :set_headers, :sync_with_repos, :user_obj_required
  after_filter :remember_location

  def url_for_svn_path(fullpath, rev=nil)
    path_parts = fullpath.split('/').reject {|fp| fp.empty?}
    path_url = {:controller => 'repository', :action => 'browse', :path => path_parts}
    if rev
      url = path_url.merge({:rev => rev})
    else
      url = path_url
    end
    url_for(url)
  end
  helper_method :url_for_svn_path

  def current_user
    @current_user
  end
  helper_method :current_user

  def rescue_action_in_public(exception)
    @exception = exception
    render 'rescues/error'
  end

  private
    # Sets the headers for each request
    def set_headers
    	@headers['Content-Type'] = "text/html; charset=utf-8"
    end

    # Remember where we are.
    # Never return to one of these controllers:
    @@remember_not = ['feed', 'login', 'user']
    def remember_location
    	if @response.headers['Status'] == '200 OK'
    		session['return_to'] = request.request_uri unless @@remember_not.include? controller_name
    	end
    end

    def sync_with_repos
      Changeset.sync_changesets
    end

    def user_obj_required
      if not session[:user_id]
        @current_user = User.find_by_login 'Public'
      else
        @current_user = User.find session[:user_id]
      end
    end

end
