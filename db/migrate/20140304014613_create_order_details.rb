class CreateOrderDetails < ActiveRecord::Migration
  def change
    create_table :order_details do |t|
      t.integer :order_id
      t.integer :product_id
      t.integer :quantity
      t.decimal :price, precision: 16, scale: 2
      t.decimal :supplier_price, precision: 16, scale: 2
      t.string :product_name
      t.integer :warranty

      t.timestamps
    end
  end
end
