class CreateProductStockUpdates < ActiveRecord::Migration
  def change
    create_table :product_stock_updates do |t|
      t.integer :product_id
      t.integer :quantity
      t.text :serial_numbers

      t.timestamps
    end
  end
end
