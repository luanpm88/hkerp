class CreateAutotasks < ActiveRecord::Migration
  def change
    create_table :autotasks do |t|
      t.string :name
      t.integer :time_interval

      t.timestamps
    end
  end
end
