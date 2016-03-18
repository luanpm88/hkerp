class AddWorksheetIdToWorksheetIntineraries < ActiveRecord::Migration
  def change
    add_column :worksheet_intineraries, :worksheet_id, :integer
  end
end
