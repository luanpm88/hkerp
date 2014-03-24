class AddTmpproductToProducts < ActiveRecord::Migration
  def change
    add_column :products, :tmpproduct, :integer
  end
end
