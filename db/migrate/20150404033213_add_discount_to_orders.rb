class AddDiscountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :discount, :integer, default: 0
  end
end
