class CreateProductPrices < ActiveRecord::Migration
  def change
    create_table :product_prices do |t|
      t.integer :product_id
      t.decimal :price
      t.decimal :supplier_price
      t.integer :supplier_id

      t.timestamps
    end
  end
end
