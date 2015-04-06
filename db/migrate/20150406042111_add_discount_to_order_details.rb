class AddDiscountToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :discount, :integer, dedault: 0
  end
end
