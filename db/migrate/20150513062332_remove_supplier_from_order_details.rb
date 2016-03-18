class RemoveSupplierFromOrderDetails < ActiveRecord::Migration
  def change
    remove_column :order_details, :supplier_id
    remove_column :order_details, :supplier_price
  end
end
