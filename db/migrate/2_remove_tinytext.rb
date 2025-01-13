class RemoveTinytext < ActiveRecord::Migration[7.2]
  def self.up
    change_column :tickets, :content, :text
  end

  def self.down
    change_column :tickets, :content, :tinytext
  end
end
