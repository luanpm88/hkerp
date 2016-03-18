class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :customer_id
      t.integer :supplier_id
      t.integer :agent_id
      t.string :shipping_place
      t.integer :payment_method_id
      t.datetime :payment_deadline

      t.timestamps
    end
  end
end
