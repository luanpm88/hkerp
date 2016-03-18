class AddRepresentativeToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :representative, :string
  end
end
