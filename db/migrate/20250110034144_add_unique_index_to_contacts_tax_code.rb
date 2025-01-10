class AddUniqueIndexToContactsTaxCode < ActiveRecord::Migration
  def change
    add_index :contacts, :tax_code, unique: false, where: "tax_code IS NOT NULL", name: "index_contacts_on_tax_code_unique"
  end
end
