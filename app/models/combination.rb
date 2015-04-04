class Combination < ActiveRecord::Base
  has_many :combination_details
  belongs_to :product
  belongs_to :user
  
  validate :valid_quantity
  
  
  #validate :prevent_save
  
  def prevent_save
    errors.add(:quantity, "prevent_save")
  end
  
  def valid_quantity
    p = Product.find(product_id)
    if quantity > p.max_combinable || quantity == 0
        errors.add(:quantity, "is not valid")
    end    
  end
  
  
end
