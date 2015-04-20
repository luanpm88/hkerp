class AddIsTipToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_tip, :boolean, default: false
  end
end
