class CreateCustomerPos < ActiveRecord::Migration
  def change
    create_table :customer_pos do |t|
      t.string :code
      t.string :filename

      t.timestamps null: false
    end
  end
end
