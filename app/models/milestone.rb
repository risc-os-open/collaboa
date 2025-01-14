class Milestone < ApplicationRecord
  has_many :tickets
  validates_presence_of :name

  def open_tickets
    self.tickets.where('status_id <= 1').count
  end

  def closed_tickets
    self.tickets.where('status_id > 1').count
  end

  def total_tickets
    self.tickets.count
  end

  def completed_tickets_percent
    return 0 if self.tickets.empty?
    (self.closed_tickets.to_f / self.total_tickets.to_f * 100).to_i
  end
end
