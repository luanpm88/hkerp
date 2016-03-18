class AddFixedAddressToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :fixed_address, :text
  end
end
