require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  
  fixtures :users
    
  def test_auth
    
    assert_equal  users(:bob), User.authenticate("bob", "test")    
    assert_nil    User.authenticate("nonbob", "test")
    
  end


  def test_passwordchange
        
    users(:longbob).change_password("nonbobpasswd")
    assert_equal users(:longbob), User.authenticate("longbob", "nonbobpasswd")
    assert_nil   User.authenticate("longbob", "longtest")
    users(:longbob).change_password("longtest")
    assert_equal users(:longbob), User.authenticate("longbob", "longtest")
    assert_nil   User.authenticate("longbob", "nonbobpasswd")
        
  end
  
  def test_disallowed_passwords
    
    u = User.new    
    u.login = "nonbob"

    u.password = u.password_confirmation = "tiny"
    assert !u.save     
    assert u.errors.invalid?('password')

    u.password = u.password_confirmation = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"
    assert !u.save     
    assert u.errors.invalid?('password')
        
    u.password = u.password_confirmation = ""
    assert !u.save    
    assert u.errors.invalid?('password')
        
    u.password = u.password_confirmation = "bobs_secure_password"
    assert u.save     
    assert u.errors.empty?
        
  end
  
  def test_bad_logins

    u = User.new  
    u.password = u.password_confirmation = "bobs_secure_password"

    u.login = "x"
    assert !u.save     
    assert u.errors.invalid?('login')
    
    u.login = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !u.save     
    assert u.errors.invalid?('login')

    u.login = ""
    assert !u.save
    assert u.errors.invalid?('login')

    u.login = "okbob"
    assert u.save  
    assert u.errors.empty?
      
  end


  def test_collision
    u = User.new
    u.login      = "existingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert !u.save
  end


  def test_create
    u = User.new
    u.login      = "nonexistingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
      
    assert u.save  
    
  end
  
  def test_sha1
    u = User.new
    u.login      = "nonexistingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert u.save
        
    assert_equal 'e5e7395b3f57d65e8ef03cfa5048f2739ebc747f', u.password
    
  end

  
end
