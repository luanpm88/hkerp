class AddBankAccountIdToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :bank_account_id, :integer
  end
end
