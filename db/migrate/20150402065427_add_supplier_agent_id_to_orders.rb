class AddSupplierAgentIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :supplier_agent_id, :integer
  end
end
