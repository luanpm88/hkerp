class CreateDeliveryDetails < ActiveRecord::Migration
  def change
    create_table :delivery_details do |t|
      t.integer :delivery_id
      t.integer :order_detail_id
      t.integer :quantity

      t.timestamps
    end
  end
end
