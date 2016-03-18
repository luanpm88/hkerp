class AddIsReturnToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :is_return, :integer, default: 0
  end
end
