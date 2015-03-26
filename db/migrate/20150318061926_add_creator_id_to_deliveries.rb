class AddCreatorIdToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :creator_id, :integer
  end
end
