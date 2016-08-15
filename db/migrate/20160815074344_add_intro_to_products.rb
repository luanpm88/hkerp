class AddIntroToProducts < ActiveRecord::Migration
  def change
    add_column :products, :intro, :text
  end
end
