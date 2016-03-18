class CreateCheckinoutRequests < ActiveRecord::Migration
  def change
    create_table :checkinout_requests do |t|
      t.integer :user_id
      t.datetime :check_time
      t.text :content
      t.integer :status

      t.timestamps
    end
  end
end
