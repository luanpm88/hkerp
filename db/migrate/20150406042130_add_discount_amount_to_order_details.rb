class AddDiscountAmountToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :discount_amount, :decimal, dedault: 0
  end
end
