class AddIsRecieveToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :is_recieved, :boolean, default: false
  end
end
