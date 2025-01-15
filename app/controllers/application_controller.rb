class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Hub single sign-on support. Run the Hub filters for all actions to ensure
  # activity timeouts etc. work properly. The login integration with Hub is
  # done using modifications to the forum's own mechanism in
  # 'lib/authentication_system.rb'.
  #
  require 'hub_sso_lib'
  include HubSsoLib::Core

  before_action :hubssolib_beforehand
  after_action  :hubssolib_afterwards

  # Rescue all exceptions (bad form) to rotate the Hub key (good) and render or
  # raise the exception again (rapid reload for default handling).
  #
  rescue_from ::Exception, with: :on_error_rotate_and_raise

  # Now Collaboa's own administrative login system.
  #
  include LoginSystem

  # See ActionController::RequestForgeryProtection for details.
  #
  protect_from_forgery

  before_action :user_obj_required
  before_action :sync_with_repos
  after_action  :remember_location

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

  # ============================================================================
  # PROTECTED INSTANCE METHODS
  # ============================================================================
  #
  protected

    # Run pagy() on a given ActiveRecord scope/collection, with a default
    # limit of 20 items per page overridden by the 'default_limit' parameter,
    # or by query parameter 'items', the latter taking precedence but being
    # capped to a list size of 200 to keep server resource usage down.
    #
    # https://github.com/ddnexus/pagy
    #
    def pagy_with_params(scope:, default_limit: 20)
      limit        = params[:items]&.to_i || default_limit
      limit        = limit.clamp(1, 200)
      pagy_options = { :limit => limit }

      # Sometimes views do e.g. "?page=&..." - i.e. the param is there, but it
      # has no value. This makes Pagy grumpy, as a #to_i turns "nil" into "0"
      # and it complains that page zero is invalid.
      #
      params.delete(:page) if params.key?(:page) && params[:page].blank?

      pagy(scope, **pagy_options)
    end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    # Renders an exception, retaining Hub login. Regenerate any exception
    # within five seconds of a previous render to 'raise' to default Rails
    # error handling, which (in non-Production modes) gives additional
    # debugging context and an inline console, but loses the Hub session
    # rotated key, so you're logged out.
    #
    def on_error_rotate_and_raise(exception)
      hubssolib_get_session_proxy()
      hubssolib_afterwards()

      if session[:last_exception_at].present?
        last_at = Time.parse(session[:last_exception_at]) rescue nil
        raise if last_at.present? && Time.now - last_at < 5.seconds
      end

      session[:last_exception_at] = Time.now.iso8601(1)

      render(
        'exception',
        layout:  'exception',
        formats: [:html],
        locals:  { exception: exception }
      )
    end

    # Remember where we are.
    # Never return to one of these controllers:
    @@remember_not = ['feed', 'login', 'user']
    def remember_location
    	if response.headers['Status'] == '200 OK'
    		session['return_to'] = request.request_uri unless @@remember_not.include? controller_name
    	end
    end

    def sync_with_repos
      Changeset.sync_changesets if SVN_ENABLED
    end

    def user_obj_required
      user_id         = session[:user_id]
      @current_user   = User.find_by_id(user_id)
      @current_user ||= User.find_by_login('Public')
    end

end
