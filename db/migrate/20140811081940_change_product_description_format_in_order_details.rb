class ChangeProductDescriptionFormatInOrderDetails < ActiveRecord::Migration
  def up
    change_column :order_details, :product_description, :text
  end

  def down
    change_column :order_details, :product_description, :string
  end
end
