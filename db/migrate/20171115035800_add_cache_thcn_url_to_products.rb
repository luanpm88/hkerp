class AddCacheThcnUrlToProducts < ActiveRecord::Migration
  def change
    add_column :products, :cache_thcn_url, :string
  end
end
