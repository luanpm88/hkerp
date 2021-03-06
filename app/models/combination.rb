class Combination < ActiveRecord::Base
  has_many :combination_details
  belongs_to :product
  belongs_to :user
  
  validate :valid_quantity
  
  
  #validate :prevent_save
  
  #after_save :update_stock_after
  
  after_save :update_order_status_names
  
  def update_order_status_names
    product.orders.where(parent_id: nil).where("delivery_status_name NOT LIKE ?", '%delivered%').each do |o|
      o.update_status_names
    end
  end
  
  def prevent_save
    errors.add(:quantity, "prevent_save")
  end
  
  def valid_quantity
    p = Product.find(product_id)
    if combined.nil? || combined
      if quantity.nil? || quantity > p.max_combinable || quantity == 0
          errors.add(:quantity, "is not valid")
      end
    else
      if quantity > product.calculated_stock
        errors.add(:quantity, "is not valid")
      end
    end
  end
  
  def update_stock_after
    self.update_attributes(stock_after: Product.find(self.product_id).calculated_stock)
    
    combination_details.each do |c_d|
      c_d.update_attributes(stock_after: Product.find(c_d.product_id).calculated_stock)
    end
  end
  
  def max_combinable
    if combined.nil? || combined
      product.max_combinable
    else
      product.calculated_stock
    end
  end
  
  
end
