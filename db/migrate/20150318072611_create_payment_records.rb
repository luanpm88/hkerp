class CreatePaymentRecords < ActiveRecord::Migration
  def change
    create_table :payment_records do |t|
      t.integer :order_id
      t.integer :accountant_id
      t.decimal :amount
      t.integer :debt_days

      t.timestamps
    end
  end
end
