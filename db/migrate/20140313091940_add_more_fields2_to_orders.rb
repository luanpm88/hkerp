class AddMoreFields2ToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :warranty_place, :string
    add_column :orders, :warranty_cost, :text
  end
end
