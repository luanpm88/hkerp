class AddIsManualCostToProducts < ActiveRecord::Migration
  def change
    add_column :products, :is_manual_cost, :boolean, default: false
  end
end
