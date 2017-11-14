class AddCacheLastOrderedToProducts < ActiveRecord::Migration
  def change
    add_column :products, :cache_last_ordered, :datetime
  end
end
