class AddAuthorEmails < ActiveRecord::Migration[7.2]
  def change
    add_column :tickets,        :author_email, :text
    add_column :ticket_changes, :author_email, :text
  end
end
