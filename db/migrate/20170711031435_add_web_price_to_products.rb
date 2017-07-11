class AddWebPriceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :web_price, :decimal, precision: 16, scale: 2
  end
end
