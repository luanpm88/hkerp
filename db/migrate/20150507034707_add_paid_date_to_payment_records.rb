class AddPaidDateToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :paid_date, :datetime
  end
end
