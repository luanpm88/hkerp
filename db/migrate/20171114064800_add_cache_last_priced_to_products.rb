class AddCacheLastPricedToProducts < ActiveRecord::Migration
  def change
    add_column :products, :cache_last_priced, :datetime
  end
end
