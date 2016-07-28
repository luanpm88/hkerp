class AddCacheSearchToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :cache_search, :text
  end
end
