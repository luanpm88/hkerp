class AddNoteToProducts < ActiveRecord::Migration
  def change
    add_column :products, :note, :text
  end
end
