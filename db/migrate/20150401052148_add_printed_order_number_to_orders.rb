class AddPrintedOrderNumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :printed_order_number, :text
  end
end
