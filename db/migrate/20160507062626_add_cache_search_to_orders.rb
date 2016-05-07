class AddCacheSearchToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :cache_search, :text
  end
end
