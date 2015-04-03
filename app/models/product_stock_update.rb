class ProductStockUpdate < ActiveRecord::Base
  validates :product_id, presence: true
  validates :quantity, presence: true
  validates :user_id, presence: true
  validate :is_import, presence: true
  
  validate :valid_serial_numbers_count
  
  belongs_to :product
  belongs_to :user
  
  before_validation :update_quantity
  
  def quantity=(num)
    self[:quantity] = num.to_s.gsub(",","")
  end
  
  def valid_serial_numbers_count
    if !quantity.nil? && Product.extract_serial_numbers(serial_numbers).count > quantity.abs
        errors.add(:serial_numbers, "can't be greater than quantity")
    end    
  end
  
  def update_quantity
    if self.is_import == 0 && !self.quantity.nil?
        self.quantity = -self.quantity
    end
  end

end
