class AddDeliveryDateToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :delivery_date, :datetime
  end
end
