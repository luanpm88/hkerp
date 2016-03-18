class RemoveTipFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :tip
    remove_column :order_details, :tip
  end
end
