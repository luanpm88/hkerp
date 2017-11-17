class AddCacheWebSearchToProducts < ActiveRecord::Migration
  def change
    add_column :products, :cache_web_search, :string, index: true
  end
end
