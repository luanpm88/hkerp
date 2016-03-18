class AddWatermarkToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :watermark, :text
  end
end
