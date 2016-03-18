class CreateUsersWorksheets < ActiveRecord::Migration
  def change
    create_table :users_worksheets do |t|
      t.integer :user_id
      t.integer :worksheet_id

      t.timestamps null: false
    end
  end
end
