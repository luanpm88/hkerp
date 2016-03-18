class AddTipToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :tip, :decimal, default: 0.00
    add_column :order_details, :tip_amount, :decimal, default: 0.00
  end
end
