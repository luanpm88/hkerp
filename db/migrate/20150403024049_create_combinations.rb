class CreateCombinations < ActiveRecord::Migration
  def change
    create_table :combinations do |t|
      t.integer :product_id
      t.integer :stock_before
      t.integer :quantity
      t.integer :stock_after

      t.timestamps
    end
  end
end
