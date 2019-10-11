class AddCacheRecentSupplierIdsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :cache_recent_supplier_ids, :text
  end
end
