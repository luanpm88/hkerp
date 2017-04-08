class AddNoPriceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :no_price, :boolean
  end
end
