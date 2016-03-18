class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.integer :order_id
      t.integer :user_id

      t.timestamps
    end
  end
end
