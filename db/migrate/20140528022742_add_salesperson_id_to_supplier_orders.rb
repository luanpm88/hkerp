class AddSalespersonIdToSupplierOrders < ActiveRecord::Migration
  def change
    add_column :supplier_orders, :salesperson_id, :integer
  end
end
