class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :sender_id
      t.text :title
      t.text :description
      t.integer :viewed, default: 0
      t.text :url
      t.text :icon
      t.text :type_name
      t.integer :item_id

      t.timestamps
    end
  end
end
