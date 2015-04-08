class AddUserIdToProductPrice < ActiveRecord::Migration
  def change
    add_column :product_prices, :user_id, :integer
  end
end
