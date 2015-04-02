class CreateProductParts < ActiveRecord::Migration
  def change
    create_table :product_parts do |t|
      t.integer :product_id
      t.integer :part_id
      t.integer :quantity, default: 1

      t.timestamps
    end
  end
end
