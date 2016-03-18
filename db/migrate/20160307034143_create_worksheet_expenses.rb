class CreateWorksheetExpenses < ActiveRecord::Migration
  def change
    create_table :worksheet_expenses do |t|
      t.string :name
      t.decimal :price
      t.string :type_name
      t.text :description
      t.integer :creator_id

      t.timestamps null: false
    end
  end
end
