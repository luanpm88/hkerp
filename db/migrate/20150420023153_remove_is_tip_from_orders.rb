class RemoveIsTipFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :is_tip
  end
end
