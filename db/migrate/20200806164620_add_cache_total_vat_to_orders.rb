class AddCacheTotalVatToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :cache_total_vat, :float
  end
end
