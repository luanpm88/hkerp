class CreateOrderStatusesOrders < ActiveRecord::Migration
  def change
    create_table :order_statuses_orders do |t|
      t.integer :order_id
      t.integer :order_status_id

      t.timestamps
    end
  end
end
