class ChangeDiscountColumnType < ActiveRecord::Migration
  def change
    change_column :orders, :discount,  :decimal, default: 0.00
    change_column :order_details, :discount,  :decimal, default: 0.00
  end
end
