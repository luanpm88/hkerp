class AddNoteToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :note, :text
  end
end
