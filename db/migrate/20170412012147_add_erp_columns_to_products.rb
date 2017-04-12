class AddErpColumnsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :erp_price_updated, :boolean, default: false
    add_column :products, :erp_imported, :boolean, default: false
  end
end
