class Tmpmanu < ActiveRecord::Base
  has_many :tmpproducts, :foreign_key => "product_manufacturer_id", :primary_key => "manufacturer_id"
end
