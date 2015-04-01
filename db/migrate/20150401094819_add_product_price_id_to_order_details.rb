class AddProductPriceIdToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :product_price_id, :integer
  end
end
