class AddBuyerCompanyToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :buyer_company, :string
  end
end
