class CreateCombinationDetails < ActiveRecord::Migration
  def change
    create_table :combination_details do |t|
      t.integer :combination_id
      t.integer :product_id
      t.integer :stock_before
      t.integer :quantity
      t.integer :stock_after

      t.timestamps
    end
  end
end
