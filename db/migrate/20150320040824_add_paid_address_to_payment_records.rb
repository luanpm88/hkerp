class AddPaidAddressToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :paid_address, :text
  end
end
