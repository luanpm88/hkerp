class AddCombinedToCombinations < ActiveRecord::Migration
  def change
    add_column :combinations, :combined, :boolean, default: true
  end
end
