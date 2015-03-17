class AddSerialNumbersToProducts < ActiveRecord::Migration
  def change
    add_column :products, :serial_numbers, :text
  end
end
