class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.text :title
      t.text :description
      t.string :image
      t.string :url
      t.boolean :viewed, null: false, default: false
      t.integer :user_id
      t.string :type

      t.timestamps
    end
  end
end
