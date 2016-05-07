class AddCacheSearchToProducts < ActiveRecord::Migration
  def change
    add_column :products, :cache_search, :text
  end
end
