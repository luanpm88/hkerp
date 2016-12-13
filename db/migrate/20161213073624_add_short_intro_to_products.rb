class AddShortIntroToProducts < ActiveRecord::Migration
  def change
    add_column :products, :short_intro, :text
  end
end
