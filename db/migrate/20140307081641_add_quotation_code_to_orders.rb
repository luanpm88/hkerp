class AddQuotationCodeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :quotation_code, :string, :default => "HK-0000-000"
  end
end
