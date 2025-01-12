require File.dirname(__FILE__) + '/../test_helper'

class MilestoneTest < Test::Unit::TestCase
  fixtures :milestones, :tickets

  def setup
    @milestone2 = Milestone.find(2)
  end

  def test_open_tickets
    assert_equal 2, @milestone2.open_tickets
  end

  def test_closed_tickets
    assert_equal 2, @milestone2.closed_tickets
  end

  def test_total_tickets
    assert_equal 4, @milestone2.total_tickets    
  end

  def test_completed_tickets_percent
    assert_equal 50, @milestone2.completed_tickets_percent
  end
end
