class AddUserIdToOrderStatusesOrders < ActiveRecord::Migration
  def change
    add_column :order_statuses_orders, :user_id, :integer
  end
end
