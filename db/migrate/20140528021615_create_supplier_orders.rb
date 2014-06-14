class CreateSupplierOrders < ActiveRecord::Migration
  def change
    create_table :supplier_orders do |t|
      t.integer :supplier_id

      t.timestamps
    end
  end
end
