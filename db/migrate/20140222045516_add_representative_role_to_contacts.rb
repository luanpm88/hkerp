class AddRepresentativeRoleToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :representative_role, :string
  end
end
