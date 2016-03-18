class AddPaidPersonToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :paid_person, :text
  end
end
