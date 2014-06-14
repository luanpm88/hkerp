class AddTaxIdToSupplierOrders < ActiveRecord::Migration
  def change
    add_column :supplier_orders, :tax_id, :integer
  end
end
