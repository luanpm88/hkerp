class AddPriceAndDescriptionToWorksheetsWorksheetExpenses < ActiveRecord::Migration
  def change
    add_column :worksheets_worksheet_expenses, :price, :decimal
    add_column :worksheets_worksheet_expenses, :description, :string
  end
end
