class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :phone
      t.string :mobile
      t.string :fax
      t.string :email
      t.string :address

      t.timestamps
    end
  end
end
