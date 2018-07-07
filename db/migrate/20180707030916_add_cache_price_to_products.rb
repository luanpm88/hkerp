class AddCachePriceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :cache_price, :decimal
  end
end
