class AddUnitToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :unit, :string
  end
end
