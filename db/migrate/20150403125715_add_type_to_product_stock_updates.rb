class AddTypeToProductStockUpdates < ActiveRecord::Migration
  def change
    add_column :product_stock_updates, :is_import, :integer
  end
end
