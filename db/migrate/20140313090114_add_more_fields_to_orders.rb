class AddMoreFieldsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :deposit, :integer
    add_column :orders, :shipping_date, :datetime
    add_column :orders, :shipping_time, :string
  end
end
