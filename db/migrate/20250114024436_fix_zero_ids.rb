class FixZeroIds < ActiveRecord::Migration[7.2]
  def up
    Ticket.find_each do | t |
      milestone_id = t.milestone_id
      part_id      = t.part_id
      severity_id  = t.severity_id
      release_id   = t.release_id
      status_id    = t.status_id

      milestone_id = nil if milestone_id == 0
      part_id      = nil if part_id      == 0
      severity_id  = nil if severity_id  == 0
      release_id   = nil if release_id   == 0
      status_id    = nil if status_id    == 0

      t.update_columns(
        milestone_id: milestone_id,
        part_id:      part_id,
        severity_id:  severity_id,
        release_id:   release_id,
        status_id:    status_id
      )
    end
  end

  def down
      milestone_id = t.milestone_id
      part_id      = t.part_id
      severity_id  = t.severity_id
      release_id   = t.release_id
      status_id    = t.status_id

      milestone_id = 0 if milestone_id == nil
      part_id      = 0 if part_id      == nil
      severity_id  = 0 if severity_id  == nil
      release_id   = 0 if release_id   == nil
      status_id    = 0 if status_id    == nil

      t.update_columns(
        milestone_id: milestone_id,
        part_id:      part_id,
        severity_id:  severity_id,
        release_id:   release_id,
        status_id:    status_id
      )
  end
end

