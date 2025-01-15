# this model expects a certain database layout and its based on the name/login pattern.
class User < ApplicationRecord

  validates_length_of     :login, :within => 3..40
  validates_uniqueness_of :login, :on => :save
  validates_presence_of   :login, :password

  attr_accessor :new_password

  validates_length_of           :password, :within => 5..40
  validates_length_of       :new_password, :within => 5..40, :allow_blank => true
  validates_confirmation_of     :password, :on => :create
  validates_confirmation_of :new_password, :on => :update

  before_create :crypt_password
  before_validation :crypt_new_password

  def self.authenticate(login, pass)
    return nil if login == 'Public'
    self.where(login: login, password: self.sha1(pass)).first
  end

  # ============================================================================
  # PROTECTED INSTANCE METHODS
  # ============================================================================
  #
  protected

    # 2025-01-13 (ADH): Woah. I'm glad we don't really use this, due to Hub.
    #
    def self.sha1(pass)
      Digest::SHA1.hexdigest("c-o-l-l-a-b-o-a--#{pass}--")
    end

    def crypt_password
      write_attribute(:password, self.class.sha1(password))
    end

    def crypt_new_password
      write_attribute("password", self.class.sha1(new_password)) if new_password.present?
    end

end
