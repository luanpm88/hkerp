class AddCheckinoutRequestIdToCheckinouts < ActiveRecord::Migration
  def change
    add_column :checkinouts, :checkinout_request_id, :integer
  end
end
