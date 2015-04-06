class AddPriceStatusNameToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :price_status_name, :string
  end
end
