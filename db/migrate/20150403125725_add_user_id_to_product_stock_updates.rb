class AddUserIdToProductStockUpdates < ActiveRecord::Migration
  def change
    add_column :product_stock_updates, :user_id, :integer
  end
end
