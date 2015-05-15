class CreateCommissionPrograms < ActiveRecord::Migration
  def change
    create_table :commission_programs do |t|
      t.text :name
      t.string :interval_type
      t.decimal :min_amount
      t.decimal :max_amount
      t.decimal :commission_rate
      t.datetime :published_at
      t.datetime :unpublished_at
      t.integer :status, default: 0      
      t.text :description
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
