class AddStatusToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :status, :integer, default: 1
  end
end
