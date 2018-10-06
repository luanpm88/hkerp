class AddInUsedToProducts < ActiveRecord::Migration
  def change
    add_column :products, :in_use, :boolean, default: true
  end
end
