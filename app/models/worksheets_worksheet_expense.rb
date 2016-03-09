class WorksheetsWorksheetExpense < ActiveRecord::Base
  belongs_to :worksheet
  belongs_to :worksheet_expense
end
