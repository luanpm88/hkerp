class AddUserIdToCombinations < ActiveRecord::Migration
  def change
    add_column :combinations, :user_id, :integer
  end
end
