class AddBuyerFaxToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :buyer_fax, :string
  end
end
