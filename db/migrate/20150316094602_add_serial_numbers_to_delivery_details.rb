class AddSerialNumbersToDeliveryDetails < ActiveRecord::Migration
  def change
    add_column :delivery_details, :serial_numbers, :text
  end
end
