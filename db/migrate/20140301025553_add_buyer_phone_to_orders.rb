class AddBuyerPhoneToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :buyer_phone, :string
  end
end
