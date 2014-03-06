class AddSupplierIdToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :supplier_id, :integer
  end
end
