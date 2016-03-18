class AddBuyerNameToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :buyer_name, :string
  end
end
