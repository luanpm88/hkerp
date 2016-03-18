class AddTaxIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :tax_id, :integer
  end
end
