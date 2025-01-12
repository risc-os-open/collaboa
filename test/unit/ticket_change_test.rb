require File.dirname(__FILE__) + '/../test_helper'

class TicketChangeTest < Test::Unit::TestCase
  fixtures :ticket_changes

  def setup
    @ticket_change = TicketChange.find(1)
  end
  
  def test_search
    q = TicketChange.search("a comment")
    exp = [{:content=>"a comment",
      :title=>"Ticket #1 comment by johan",
      :link=>{:id=>1, :controller=>"/tickets", :action=>"show"}}]
    assert_equal exp, q
  end

  def test_each_log
    change = TicketChange.new do |c|
      c.log = {'Status' => %w{Open Fixed}, 'Part' => %w{Part1 Part2}}
    end
    result = []
    change.each_log{|c| result << c}
    assert_equal [["Status", "Open", "Fixed"], ["Part", "Part1", "Part2"]], result
    
    #result = []
    #@ticket_change.each_log{|c| result << c}
    #assert_equal [["Status", "Open", "Fixed"], ["Part", "Part1", "Part2"]], result
  end
  
  def test_empty
    change = TicketChange.new do |c|
      c.comment = 'a comment'
      c.log = {'Part' => %w{Part1 Part2}}
      c.attachment = 'file.txt'
    end
    assert !change.empty?
    change.comment = nil
    assert !change.empty?
    change.log = {}
    assert !change.empty?
    change.attachment = nil
    assert change.empty?
  end
end
