class AddSalespersonIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :salesperson_id, :integer
  end
end
