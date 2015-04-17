class AddStatusToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :status, :integer, default: 1
  end
end
