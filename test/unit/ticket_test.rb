require File.dirname(__FILE__) + '/../test_helper'

class TicketTest < Test::Unit::TestCase
  fixtures :tickets, :parts, :milestones, :severities, :status
  fixtures :releases, :ticket_changes#, :attachments           

  def setup
    @ticket = Ticket.find(1)
    @ticket2 = Ticket.find(2)
  end
  
  def test_search
    q = Ticket.search("first test ticket")
    exp  = [{:content=>"Just testing",
      :title=>"first test ticket",
      :link=>{:id=>1, :controller=>"/tickets", :action=>"show"}}]
    assert_equal exp, q
  end
  
  def test_find_by_filter
    params = {"status"=>"1", "action"=>"filter", "controller"=>"tickets"}
    tickets = Ticket.find_by_filter(params)
    assert_equal 2, tickets.size
  end
  
  def test_find_by_filter2
    # Will find all tickets
    params = {"stat';us"=>"1", "action"=>"filter", "controller"=>"tickets"}
    tickets = Ticket.find_by_filter(params)
    assert_equal 4, tickets.size
  end
  
  def test_find_by_filter3
    params = {"milestone"=>"1", "action"=>"filter", "controller"=>"tickets"}
    tickets = Ticket.find_by_filter(params)
    assert_equal 0, tickets.size
  end

  def test_edit
    params =  {:ticket => {:part_id => 2, 
                    :release_id => 2, 
                    :summary => "edited summary", 
                    :severity_id => 1, 
                    :status_id => 1, 
                    :milestone_id => 1},
                :change => {:attachment => "", 
                            :author => "bob", 
                            :comment => ""}
              }
    
    assert @ticket.save(params)
    change = @ticket.ticket_changes.last

    assert_equal 2, @ticket.ticket_changes.size
    assert_equal 'edited summary', @ticket.summary
    assert_equal 2, @ticket.part_id
    assert_equal 2, @ticket.release_id
    assert_not_nil change.log
    assert_equal 4, change.log.size
    assert_equal ["first test ticket", "edited summary"], change.log['Summary']
    assert_equal ["Unspecified", "0.2"], change.log['Release']
    assert_equal ["Part 1", "Part 2"], change.log['Part']
  end
  
  def test_edit_with_no_changes
    params =  {:ticket => {:part_id => 2, 
                    :release_id => 2, 
                    :summary => "second test ticket", 
                    :severity_id => 2, 
                    :status_id => 2, 
                    :milestone_id => 2},
                :change => {:attachment => "", 
                            :author => "bob", 
                            :comment => ""}
              }

    assert !@ticket2.save(params)
    assert_equal "No changes has been made", @ticket2.errors['base']
  end
  
  def test_create
    ticket = Ticket.new(:author => 'bob',
                        :part_id => 2, 
                        :release_id => 2, 
                        :summary => "new ticket summary", 
                        :severity_id => 1, 
                        :status_id => 1, 
                        :milestone_id => 1,
                        :content => 'some random description',
                        :author_host => '127.0.0.1')
    assert ticket
  end
  
  def test_validations
    @ticket.author = nil
    assert !@ticket.valid?
    
    @ticket.author = 'foo'
    @ticket.summary = nil
    assert !@ticket.valid?
    
    @ticket.author = 'foo'
    @ticket.summary = 'bar'
    @ticket.content = nil
    assert !@ticket.valid?
  end
end
