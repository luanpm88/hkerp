class AddRepresentativePhoneToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :representative_phone, :string
  end
end
