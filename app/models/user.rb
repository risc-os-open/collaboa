# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base
  
  validates_length_of :login, :within => 3..40
  validates_length_of :password, :within => 5..40
  validates_presence_of :login, :password
  validates_presence_of :password_confirmation, :on => :create
  validates_uniqueness_of :login, :on => :save
  validates_confirmation_of :password, :on => :create
  validates_length_of :new_password, :within => 5..40, :allow_nil => true
  validates_confirmation_of :new_password, :on => :update
  
  attr_reader :new_password
  
  def new_password=(pw)
    @new_password = pw
  end
  
  before_validation { |record| record.new_password = nil if record.new_password.empty? rescue nil }
  before_validation { |record| record.new_password_confirmation = nil if record.new_password_confirmation.empty? rescue nil }
  before_validation :crypt_new_password
  
  before_create :crypt_password  

  def self.authenticate(login, pass)
    return nil if login == 'Public'
    find_first ["login = ? AND password = ?", login, sha1(pass)]
  end  

  def change_password(pass)
    update_attribute :password, self.class.sha1(pass)
  end
    
  protected
    def self.sha1(pass)
      Digest::SHA1.hexdigest("c-o-l-l-a-b-o-a--#{pass}--")
    end
  
    def crypt_password
      write_attribute :password, self.class.sha1(password)
    end   
    
    def crypt_new_password
      write_attribute("password", self.class.sha1(new_password)) if new_password
    end
end
