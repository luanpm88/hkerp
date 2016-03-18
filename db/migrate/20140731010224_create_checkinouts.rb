class CreateCheckinouts < ActiveRecord::Migration
  def change
    create_table :checkinouts do |t|
      t.integer :user_id
      t.datetime :check_time

      t.timestamps
    end
  end
end
