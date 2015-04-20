class AddTipStatusNameToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :tip_status_name, :string
  end
end
