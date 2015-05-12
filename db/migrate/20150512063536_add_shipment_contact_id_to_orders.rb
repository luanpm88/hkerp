class AddShipmentContactIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shipment_contact_id, :integer
  end
end
