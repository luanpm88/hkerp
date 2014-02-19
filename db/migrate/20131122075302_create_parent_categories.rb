class CreateParentCategories < ActiveRecord::Migration
  def change
    create_table :parent_categories do |t|
      t.integer :category_id
      t.integer :parent_id
    end
  end
end
