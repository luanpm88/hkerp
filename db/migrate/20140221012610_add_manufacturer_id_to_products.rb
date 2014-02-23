class AddManufacturerIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :manufacturer_id, :integer
  end
end
