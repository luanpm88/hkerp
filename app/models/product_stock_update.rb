class ProductStockUpdate < ActiveRecord::Base
  validates :product_id, presence: true
  validates :quantity, presence: true
  validates :user_id, presence: true
  validates :note, presence: true
  validates :is_import, presence: true
  
  validate :valid_serial_numbers_count
  
  belongs_to :product
  belongs_to :user
  
  before_validation :update_quantity
  before_validation :fix_serial_numbers  
  
  after_save :update_order_status_names
  
  def update_order_status_names
    product.orders.where(parent_id: nil).where("delivery_status_name NOT LIKE ?", '%delivered%').each do |o|
      o.update_status_names
    end
  end
  
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
  
  def fix_serial_numbers
    self.serial_numbers = Product.extract_serial_numbers(serial_numbers).join("\r\n")
  end

end
