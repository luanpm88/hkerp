class AddPublicPriceToProductPrices < ActiveRecord::Migration
  def change
    add_column :product_prices, :public_price, :decimal, default: 0.00
  end
end
