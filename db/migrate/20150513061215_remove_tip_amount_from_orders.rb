class RemoveTipAmountFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :tip_amount
  end
end
