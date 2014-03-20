class AddTmpcatTocategories < ActiveRecord::Migration
  def change
    add_column :categories, :tmpcat, :integer
  end
end
