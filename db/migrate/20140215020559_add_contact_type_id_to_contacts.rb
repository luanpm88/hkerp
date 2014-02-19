class AddContactTypeIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :contact_type_id, :integer
  end
end
