class AddIsManualPriceUpdateToProducts < ActiveRecord::Migration
  def change
    add_column :products, :is_manual_price_update, :boolean, default: false
  end
end
