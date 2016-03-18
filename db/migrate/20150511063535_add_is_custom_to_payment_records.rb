class AddIsCustomToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :is_custom, :boolean, default: false
  end
end
