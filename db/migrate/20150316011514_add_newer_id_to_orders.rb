class AddNewerIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :newer_id, :integer
  end
end
