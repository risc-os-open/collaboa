require File.dirname(__FILE__) + '/../test_helper'
require 'repository_controller'

# Re-raise errors caught by the controller.
class RepositoryController; def rescue_action(e) raise e end; end

class RepositoryControllerTest < Test::Unit::TestCase
  def setup
    @controller = RepositoryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_view_changesets
    get :changesets
    assert_response :success
    assert_template 'changesets'
  end
  
  def test_show_changeset
    r = get :show_changeset, 'revision' => "3"
    assert_response :success
    assert_template 'show_changeset'
    assert_equal "edited file1.txt again", r.template_objects['changeset'].log
    assert_equal 1, r.template_objects['changeset'].changes.size
  end
  
  def test_index
    get :index
    assert_response :redirect
    assert_redirected_to(:action => 'browse')
  end

  def test_browse
    get :browse, 'path' => []
    assert_response :success
    assert_template 'browse'
    
    r = get :browse, 'path' => ["html"]
    assert_response :success
    assert_template 'browse'
  end
  
  def test_browse_file
    get :browse, 'path' => ["file.txt"]
    assert_response :redirect
    assert_redirected_to(:action => 'view_file')
    
    r = get :view_file, 'path' => ["file.txt"]
    assert_response :success
    assert_template 'showfile'
    assert_equal "I am the silly test file!\n", r.template_objects['file'].contents
  end
  
  def test_alternative_formats
    get :view_file, 'path' => ["file.txt"], :format => 'txt'
    assert_response :success
    
    get :view_file, 'path' => ["file.txt"], :format => 'raw'
    assert_response :success
  end
  
  def test_routes
    # file viewer
    wanted_file = { :controller => 'repository', :action => 'view_file', :path => ["file.txt"] }
    #assert_generates "repository/file/file1.txt", wanted_file
    assert_recognizes wanted_file, "repository/file/file.txt"
    
    # file view2
    wanted_file = { :controller => 'repository', :action => 'view_file', :path => ["html", "html_file.html"] }
    #assert_generates "repository/file/file1.txt", wanted_file
    assert_recognizes wanted_file, "repository/file/html/html_file.html"
    
    # browser
    wanted_dir = { :controller => 'repository', :action => 'browse', :path => ["html"] }
    #assert_generates "repository/browse/html", wanted_dir
    assert_recognizes wanted_dir, "repository/browse/html"
    
    # a specific changeset
    wanted = { :controller => 'repository', :action => 'show_changeset', :revision => "1" }
    #assert_generates "repository/changesets/1", wanted
    assert_recognizes wanted, "repository/changesets/1"
  end
end
