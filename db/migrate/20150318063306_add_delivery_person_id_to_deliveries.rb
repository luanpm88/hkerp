class AddDeliveryPersonIdToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :delivery_person_id, :integer
  end
end
