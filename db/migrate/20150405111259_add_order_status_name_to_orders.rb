class AddOrderStatusNameToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_status_name, :string
  end
end
