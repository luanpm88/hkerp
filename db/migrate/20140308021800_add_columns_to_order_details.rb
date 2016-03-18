class AddColumnsToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :product_description, :string
  end
end
