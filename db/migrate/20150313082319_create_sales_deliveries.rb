class CreateSalesDeliveries < ActiveRecord::Migration
  def change
    create_table :sales_deliveries do |t|
      t.integer :order_id

      t.timestamps
    end
  end
end
