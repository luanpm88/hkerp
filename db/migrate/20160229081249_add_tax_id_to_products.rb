class AddTaxIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :tax_id, :integer
  end
end
