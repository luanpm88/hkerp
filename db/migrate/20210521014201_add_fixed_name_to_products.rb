class AddFixedNameToProducts < ActiveRecord::Migration
  def change
    add_column :products, :fixed_name, :string, default: nil
  end
end
