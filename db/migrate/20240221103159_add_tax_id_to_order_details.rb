class AddTaxIdToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :tax_id, :integer
  end
end
