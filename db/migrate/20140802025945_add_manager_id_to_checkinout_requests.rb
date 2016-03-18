class AddManagerIdToCheckinoutRequests < ActiveRecord::Migration
  def change
    add_column :checkinout_requests, :manager_id, :integer
  end
end
