class AddCacheSearchToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :cache_search, :text
  end
end
