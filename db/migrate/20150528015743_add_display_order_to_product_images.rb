class AddDisplayOrderToProductImages < ActiveRecord::Migration
  def change
    add_column :product_images, :display_order, :integer
  end
end
