class CreateCustomerPosOrders < ActiveRecord::Migration
  def change
    create_table :customer_pos_orders do |t|
      t.integer :order_id
      t.integer :customer_po_id

      t.timestamps null: false
    end
  end
end
