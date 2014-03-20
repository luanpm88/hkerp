class AddPhoneExtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone_ext, :string
  end
end
