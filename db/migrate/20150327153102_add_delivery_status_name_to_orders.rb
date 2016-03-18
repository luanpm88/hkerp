class AddDeliveryStatusNameToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_status_name, :string
  end
end
