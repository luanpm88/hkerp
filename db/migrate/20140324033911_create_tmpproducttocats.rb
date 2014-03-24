class CreateTmpproducttocats < ActiveRecord::Migration
  def change
    create_table :tmpproducttocats do |t|
      t.text :product_id
      t.text :category_id
      t.text :product_ordering

      t.timestamps
    end
  end
end
