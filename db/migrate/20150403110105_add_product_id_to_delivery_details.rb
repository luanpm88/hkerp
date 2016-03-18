class AddProductIdToDeliveryDetails < ActiveRecord::Migration
  def change
    add_column :delivery_details, :product_id, :integer
  end
end
