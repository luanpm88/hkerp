class AddStatusToWorksheets < ActiveRecord::Migration
  def change
    add_column :worksheets, :status, :string, default: "active"
  end
end
