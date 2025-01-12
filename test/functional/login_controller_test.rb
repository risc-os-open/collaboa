require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Raise errors beyond the default web-based presentation
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  
  fixtures :users
  
  def setup
    @controller = LoginController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
  end
  
  def test_auth_bob
    @request.session[:return_to] = "/bogus/location"

    post :login, "user_login" => "bob", "user_password" => "test"
    assert_session_has :user_id

    assert_equal users(:bob).id, @response.session[:user_id]
    
    assert_redirect_url "http://localhost/bogus/location"
  end

  def test_invalid_login
    post :login, "user_login" => "bob", "user_password" => "not_correct"
     
    assert_session_has_no :user_id
    
    assert_template_has "message"
    assert_template_has "login"
  end
  
  def test_login_logoff

    post :login, "user_login" => "bob", "user_password" => "test"
    assert_session_has :user_id

    get :logout
    assert_session_has_no :user

  end
  
end
