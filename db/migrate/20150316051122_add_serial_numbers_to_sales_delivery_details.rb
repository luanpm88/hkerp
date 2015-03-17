class AddSerialNumbersToSalesDeliveryDetails < ActiveRecord::Migration
  def change
    add_column :sales_delivery_details, :serial_numbers, :text
  end
end
