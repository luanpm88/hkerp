class Tmpproducttocat < ActiveRecord::Base
  belongs_to :tmpproduct, :foreign_key => "product_id", :primary_key => "product_id"
  belongs_to :tmpcat, :foreign_key => "category_id", :primary_key => "category_id"
end
