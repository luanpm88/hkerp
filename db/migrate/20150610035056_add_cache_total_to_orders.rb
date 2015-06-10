class AddCacheTotalToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :cache_total, :decimal
  end
end
