class AddDebtDateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :debt_date, :datetime
  end
end
