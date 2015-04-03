class Combination < ActiveRecord::Base
  has_many :combination_details
  belongs_to :product
  
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
  
  def proccess
    combination_details.each do |cd|
      p = Product.find(cd.product_id)
      p.remove_serial_numbers(Product.extract_serial_numbers(cd.serial_numbers))
      
      new_stock = p.stock - cd.quantity
      p.update_attributes(stock: new_stock)
      
      p = Product.find(cd.product_id)
      cd.update_attributes(stock_after: p.stock)
      cd.save
    end
    
    p = Product.find(self.product_id)
    p.update_attributes(stock: p.stock + self.quantity)
    update_attributes(stock_after: Product.find(p.id).stock)
    save
  end
  
  #def combine_parts(quantity)
  #  if quantity.to_i <= max_combinable && quantity.to_i != 0
  #    com = Combination.new(product_id: self.id, stock_before: self.stock, quantity: quantity.to_i)
  #    
  #    parts.each do |p|
  #      num = self.product_parts.where(part_id: p.id).first.quantity.to_i*quantity.to_i
  #      new_stock = p.stock - num
  #      
  #      com_detail = com.combination_details.new(product_id: p.id, stock_before: p.stock, quantity: num)
  #      
  #      p.update_attributes(stock: new_stock)
  #      
  #      com_detail.stock_after = Product.find(p.id).stock
  #    end
  #    
  #    n_stock = self.stock+quantity.to_i
  #    self.update_attributes(stock: n_stock)
  #    
  #    com.stock_after = Product.find(self.id).stock
  #    
  #    com.save
  #    
  #    return true
  #  else
  #    return false
  #  end
  #end
end
