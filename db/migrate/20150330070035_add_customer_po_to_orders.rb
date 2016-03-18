class AddCustomerPoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :customer_po, :string
  end
end
