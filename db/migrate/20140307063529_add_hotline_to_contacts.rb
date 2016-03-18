class AddHotlineToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :hotline, :string
  end
end
