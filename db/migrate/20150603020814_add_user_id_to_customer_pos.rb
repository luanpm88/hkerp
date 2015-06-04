class AddUserIdToCustomerPos < ActiveRecord::Migration
  def change
    add_column :customer_pos, :user_id, :integer
  end
end
