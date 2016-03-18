class CreateWorksheetsWorksheetExpenses < ActiveRecord::Migration
  def change
    create_table :worksheets_worksheet_expenses do |t|
      t.integer :worksheet_id
      t.integer :worksheet_expense_id
    end
  end
end
