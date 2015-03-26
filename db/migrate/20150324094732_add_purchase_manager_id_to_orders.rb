class AddPurchaseManagerIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :purchase_manager_id, :integer
  end
end
