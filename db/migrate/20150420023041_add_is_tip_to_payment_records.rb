class AddIsTipToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :is_tip, :boolean, default: false
  end
end
