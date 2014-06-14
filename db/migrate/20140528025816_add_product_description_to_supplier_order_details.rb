class AddProductDescriptionToSupplierOrderDetails < ActiveRecord::Migration
  def change
    add_column :supplier_order_details, :product_description, :text
  end
end
