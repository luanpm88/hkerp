class AddPrintNameToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :print_name, :string
  end
end
