class AddDebtDateToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :debt_date, :datetime
  end
end
