class Part < ApplicationRecord
  has_many :tickets
  validates_presence_of :name
end
