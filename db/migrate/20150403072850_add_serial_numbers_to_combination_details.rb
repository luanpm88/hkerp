class AddSerialNumbersToCombinationDetails < ActiveRecord::Migration
  def change
    add_column :combination_details, :serial_numbers, :text
  end
end
