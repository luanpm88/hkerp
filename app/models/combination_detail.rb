class CombinationDetail < ActiveRecord::Base
  belongs_to :combination
  belongs_to :product
  
  validate :valid_serial_numbers
  validate :serial_numbers_remain_can_not_greater_than_stock_remain
  
  def valid_serial_numbers
    if Product.extract_serial_numbers(serial_numbers).count > quantity
        errors.add(:serial_numbers, "can not be greater than quantity")
    end
  end
  
  def serial_numbers_remain_can_not_greater_than_stock_remain
    p = Product.find(product_id)
    
    removed_serial_number = []
    Product.extract_serial_numbers(serial_numbers).each do |number|
      if Product.extract_serial_numbers(p.serial_numbers).include?(number)
        removed_serial_number << number
      end      
    end
    
    if Product.extract_serial_numbers(p.serial_numbers).count - removed_serial_number.count > p.stock - quantity
        errors.add(:serial_numbers, "remains can not be greater than stock remain")
    end    
  end
end
