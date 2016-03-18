class AddTaxCodeToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :tax_code, :string

  end
end
