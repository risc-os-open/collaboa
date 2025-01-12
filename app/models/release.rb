class Release < ActiveRecord::Base
  has_many :tickets
end
