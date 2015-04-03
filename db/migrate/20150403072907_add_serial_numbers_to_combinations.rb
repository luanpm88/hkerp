class AddSerialNumbersToCombinations < ActiveRecord::Migration
  def change
    add_column :combinations, :serial_numbers, :text
  end
end
