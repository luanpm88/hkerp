class AddPaymentStatusNameToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :payment_status_name, :string
  end
end
