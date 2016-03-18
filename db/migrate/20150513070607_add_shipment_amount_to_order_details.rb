class AddShipmentAmountToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :shipment_amount, :decimal, default: 0.00
  end
end
