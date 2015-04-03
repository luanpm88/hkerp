class ProductStockUpdate < ActiveRecord::Base
  validates :product_id, presence: true
  validates :quantity, presence: true
  
  validate :valid_serial_numbers_count
  
  belongs_to :product
  
  
  def quantity=(num)
    self[:quantity] = num.gsub(",","")
  end
  
  def valid_serial_numbers_count
    if Product.extract_serial_numbers(serial_numbers).count > quantity
        errors.add(:serial_numbers, "can't be greater than quantity")
    end    
  end
end
