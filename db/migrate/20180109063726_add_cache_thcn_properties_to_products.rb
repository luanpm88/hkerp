class AddCacheThcnPropertiesToProducts < ActiveRecord::Migration
  def change
    add_column :products, :cache_thcn_properties, :text
  end
end
