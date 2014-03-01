class AddBuyerTaxCodeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :buyer_tax_code, :string
  end
end
