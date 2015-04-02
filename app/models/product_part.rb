class ProductPart < ActiveRecord::Base
  belongs_to :product
  belongs_to :part, :class_name => "Product"
end
