class FixIndices < ActiveRecord::Migration[8.0]
  def change
    add_index :tickets, :part_id
    add_index :tickets, :severity_id
    add_index :tickets, :release_id
    add_index :tickets, :milestone_id

    add_index :ticket_changes, :ticket_id
  end
end
