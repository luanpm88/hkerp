class AddNoteToProductStockUpdates < ActiveRecord::Migration
  def change
    add_column :product_stock_updates, :note, :text
  end
end
