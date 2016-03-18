class CreateWorksheetIntineraries < ActiveRecord::Migration
  def change
    create_table :worksheet_intineraries do |t|
      t.string :start_address
      t.string :end_address
      t.datetime :start_at
      t.datetime :end_at
      t.decimal :distance
      t.text :description

      t.timestamps null: false
    end
  end
end
