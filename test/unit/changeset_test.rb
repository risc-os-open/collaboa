require File.dirname(__FILE__) + '/../test_helper'

require 'repository'

class ChangesetTest < Test::Unit::TestCase
  fixtures :changesets

  def setup
    @changeset1 = Changeset.find(1)
  end
  
  def test_sync_changesets
    assert Changeset.sync_changesets  # run sync_changesets and make sure it goes ok
    
    assert_equal "importing test data", @changeset1.log
    
    assert_equal "edited file1.txt", Changeset.find(2).log
    assert_equal 2, Changeset.find(2).revision
    assert_equal "johan", Changeset.find(2).author
    
    assert_equal "edited file1.txt again", Changeset.find(3).log
    assert_equal 3, Changeset.find(3).revision
    assert_equal "johan", Changeset.find(3).author
    assert_equal "file1.txt", Changeset.find(3).changes.first.path
    assert_equal "M", Changeset.find(3).changes.first.name
  end
  
  def test_search
    q = Changeset.search("importing")
    exp = [{:content=>"importing test data",
      :title=>"Changeset #1",
      :link=>
       {:revision=>1, :controller=>"/repository", :action=>"show_changeset"}}]
    assert_equal exp, q
  end

end
