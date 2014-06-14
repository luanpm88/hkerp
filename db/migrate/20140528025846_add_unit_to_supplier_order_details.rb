class AddUnitToSupplierOrderDetails < ActiveRecord::Migration
  def change
    add_column :supplier_order_details, :unit, :text
  end
end
