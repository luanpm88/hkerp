class AddTipToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :tip, :decimal, default: 0.00
    add_column :orders, :tip_amount, :decimal, default: 0.00
  end
end
