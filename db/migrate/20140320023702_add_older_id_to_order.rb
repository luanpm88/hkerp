class AddOlderIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :older_id, :integer
  end
end
