class AddCacheDisplayNameToProducts < ActiveRecord::Migration
  def change
    add_column :products, :cache_display_name, :string
  end
end
