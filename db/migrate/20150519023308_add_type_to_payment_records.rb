class AddTypeToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :type_name, :string
  end
end
