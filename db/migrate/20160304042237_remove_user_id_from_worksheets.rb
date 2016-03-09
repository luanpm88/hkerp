class RemoveUserIdFromWorksheets < ActiveRecord::Migration
  def change
    remove_column :worksheets, :user_id, :integer
  end
end
