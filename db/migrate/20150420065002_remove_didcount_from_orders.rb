class RemoveDidcountFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :discount
    remove_column :order_details, :discount
  end
end
