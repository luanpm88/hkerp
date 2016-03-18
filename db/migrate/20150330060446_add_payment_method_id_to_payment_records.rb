class AddPaymentMethodIdToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :payment_method_id, :integer
  end
end
