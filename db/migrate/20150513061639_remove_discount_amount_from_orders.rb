class RemoveDiscountAmountFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :discount_amount
  end
end
