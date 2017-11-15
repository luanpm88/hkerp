class AddErpSoldOutToProducts < ActiveRecord::Migration
  def change
    add_column :products, :erp_sold_out, :boolean, default: false
  end
end
