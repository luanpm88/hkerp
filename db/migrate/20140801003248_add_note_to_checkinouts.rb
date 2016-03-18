class AddNoteToCheckinouts < ActiveRecord::Migration
  def change
    add_column :checkinouts, :note, :text
  end
end
