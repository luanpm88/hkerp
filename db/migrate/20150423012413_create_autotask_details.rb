class CreateAutotaskDetails < ActiveRecord::Migration
  def change
    create_table :autotask_details do |t|
      t.integer :autotask_id
      t.integer :item_count

      t.timestamps
    end
  end
end
