class AddIsMineToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :is_mine, :boolean, :default => false
  end
end
