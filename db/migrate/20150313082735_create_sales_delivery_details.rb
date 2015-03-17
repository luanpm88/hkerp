class CreateSalesDeliveryDetails < ActiveRecord::Migration
  def change
    create_table :sales_delivery_details do |t|
      t.integer :sales_delivery_id
      t.integer :order_detail_id
      t.integer :quantity

      t.timestamps
    end
  end
end
