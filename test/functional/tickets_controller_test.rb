require File.dirname(__FILE__) + '/../test_helper'
require 'tickets_controller'

# Re-raise errors caught by the controller.
class TicketsController; def rescue_action(e) raise e end; end

class TicketsControllerTest < Test::Unit::TestCase
  fixtures :tickets, :parts, :milestones, :severities, :status
  fixtures :releases, :ticket_changes#, :attachments  

  def setup
    @controller = TicketsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    r = get :index
    assert_response :redirect
    assert_redirected_to :action => 'filter', :status => 1
  end
  
  def test_filter
    r = get :filter, :status => 1
    assert_response :success
    assert_template 'index'
    assert  r.template_objects['tickets']
  end
  
  def test_show
    r = get :show, :id => 1
    assert_response :success
    assert_template 'show'
    assert  r.template_objects['ticket']
  
    assert  r.template_objects['parts']
    assert  r.template_objects['milestones']
    assert  r.template_objects['severities']
    assert  r.template_objects['status']
    assert  r.template_objects['releases']
  end
  
  def test_add_comment  
    r = post :show, :id => 1, :change => {:author => 'john', :comment => 'this is a comment'}
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1

    g = get :show, :id => 1
    assert_equal 'this is a comment', g.template_objects['ticket'].ticket_changes.last.comment
  end
  
  def test_add_invalid_comment_without_author
    r = post :show, :id => 1, :change => {:author => '', :comment => 'this is a comment'}
    assert_response :success
    assert r.template_objects['change'].errors.on('author')
  end
  
  def test_edit
    r = post :show, :id => 2, :ticket => {:part_id => 2, 
                                          :author => "bob", 
                                          :release_id => 0, 
                                          :summary => "blabla", 
                                          :content => "this is a ticket", 
                                          :severity_id => 2, 
                                          :milestone_id => 2}, 
                              :change => {:author => 'john', :comment => 'blabla'}
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 2  
  end
  
  def test_invalid_edit  
    r = post :show, :id => 2, :ticket => {  :part_id => 2, 
                                            :author => "bob", 
                                            :release_id => "", 
                                            :summary => "", 
                                            :content => "this is a ticket", 
                                            :severity_id => 2, 
                                            :milestone_id=>2
                            }, :change => {:author => 'john', :comment => 'fubar'}  
    assert_response :success
    assert r.template_objects['ticket'].errors.on('summary')
  end
  
  def test_get_new
    r = get :new
    assert_response :success
    assert_template 'new'
    assert  r.template_objects['ticket']

    assert  r.template_objects['parts']
    assert  r.template_objects['milestones']
    assert  r.template_objects['severities']
    assert  r.template_objects['releases']
  end
  
  def test_create
    post :new, "ticket" => {  "part_id" => "1", 
                              "author" => "bob", 
                              "release_id" => "", 
                              "summary" => "testing", 
                              "content" => "this is a ticket", 
                              "severity_id" => "1", 
                              "milestone_id"=>"1"}
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 5
  end
  
  def test_invalid_create
    r = post :new, "ticket" => {  "part_id" => "1", 
                              "author" => "bob", 
                              "release_id" => "", 
                              "summary" => "", 
                              "content" => "this is a ticket", 
                              "severity_id" => "1", 
                              "milestone_id"=>"1"}
    assert_response :success
    assert r.template_objects['ticket'].errors.on('summary')
  end
  
end
