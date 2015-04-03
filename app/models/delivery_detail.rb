class DeliveryDetail < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  belongs_to :delivery
  belongs_to :order_detail
  belongs_to :product
  
  before_save :fix_serial_numbers
  
  def total
    (order_detail.price * quantity).abs
  end
  
  def formated_total
    Order.format_price(total)
  end
  
  def serial_numbers_extracted
    arr = []
    
    if !serial_numbers.nil?
      serial_numbers.split("\r\n").each do |line|
        item = line.strip
        if item.length < 40 && item.length > 4
          arr << item
        end      
      end
    end
    
    return arr
  end
  
  def check_valid_serial_numbers
    serial_numbers_extracted.count <= quantity.abs
  end
  
  def fix_serial_numbers
    self.serial_numbers = serial_numbers_extracted.join("\r\n")
  end
  
  def serial_numbers_html
    serial_numbers.gsub("\r\n","<br />")
  end
end
