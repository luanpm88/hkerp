class AddListedPriceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :listed_price, :decimal, precision: 16, scale: 2
  end
end
