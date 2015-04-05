class AddDiscountAmountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :discount_amount, :decimal
  end
end
