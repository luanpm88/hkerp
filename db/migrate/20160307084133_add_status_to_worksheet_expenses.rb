class AddStatusToWorksheetExpenses < ActiveRecord::Migration
  def change
    add_column :worksheet_expenses, :status, :string
  end
end
