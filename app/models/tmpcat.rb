class Tmpcat < ActiveRecord::Base
  has_many :tmpproducttocats, :foreign_key => "category_id", :primary_key => "category_id"
  has_many :tmpproducts, :through => :tmpproducttocats, :foreign_key => "product_id", :primary_key => "product_id"
end
