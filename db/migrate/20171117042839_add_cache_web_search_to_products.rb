class AddCacheWebSearchToProducts < ActiveRecord::Migration
  def change
    add_column :products, :cache_web_search, :string
  end
end
