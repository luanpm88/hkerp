class AddCustomerIdToProductPrices < ActiveRecord::Migration
  def change
    add_column :product_prices, :customer_id, :integer
  end
end
