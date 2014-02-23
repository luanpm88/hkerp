class AddBankToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :bank, :string
  end
end
