class AddAttNoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ATT_No, :string
  end
end
