class AddPurchaserIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :purchaser_id, :integer
  end
end
