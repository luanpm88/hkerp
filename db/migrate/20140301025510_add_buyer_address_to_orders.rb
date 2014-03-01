class AddBuyerAddressToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :buyer_address, :string
  end
end
