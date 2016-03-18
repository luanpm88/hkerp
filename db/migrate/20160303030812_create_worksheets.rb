class CreateWorksheets < ActiveRecord::Migration
  def change
    create_table :worksheets do |t|
      t.integer :user_id
      t.integer :creator_id

      t.timestamps null: false
    end
  end
end
