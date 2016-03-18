class AddContactTypesCacheToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :contact_types_cache, :string
  end
end
