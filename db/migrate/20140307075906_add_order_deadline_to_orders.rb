class AddOrderDeadlineToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_deadline, :datetime
  end
end
