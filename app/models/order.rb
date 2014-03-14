class Order < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  validates :customer_id, presence: true
  validates :order_date, presence: true
  validates :order_deadline, presence: true
  
  belongs_to :customer, :class_name => "Contact"
  #belongs_to :supplier, :class_name => "Contact"
  belongs_to :tax
  belongs_to :payment_method
  belongs_to :salesperson, :class_name => "User"
  
  has_many :order_details, :dependent => :destroy
  
  accepts_nested_attributes_for :order_details
  
  #before_create :create_quotation_code
  
  def total
    total = 0;
    order_details.each {|item|
      total = total + item.total
    }
    return total
  end
  
  def total_vat
    total = 0;
    order_details.each {|item|
      total = total + item.total
    }
    return total*(tax.rate/100+1)
  end
  
  def vat_amount
    return total*(tax.rate/100)
  end
  
  def formated_total
    number_to_currency(total, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_total_vat
    number_to_currency(total_vat, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_vat_amount
    number_to_currency(vat_amount, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_warranty_cost
    number_to_currency(total, precision: 0, unit: '', delimiter: ".")
  end
  
  def warranty_cost=(new_warranty_cost)
    self[:warranty_cost] = new_warranty_cost.gsub(/\,/, '')
  end
  
  def create_quotation_code
    lastest = Order.where("order_date::text LIKE :val", :val => order_date.strftime("%Y")+"-"+order_date.strftime("%m")+"%").order("quotation_code DESC").first
    
    if !lastest.nil? && !lastest.quotation_code.nil?
      num = lastest.quotation_code.split(/\-/).last.to_i + 1
      self.quotation_code = "HK-"+order_date.strftime("%Y")+order_date.strftime("%m")+"-"+num.to_s.rjust(3, '0')
    else
      self.quotation_code = "HK-"+order_date.strftime("%Y")+order_date.strftime("%m")+"-"+1.to_s.rjust(3, '0')
    end
  end

end
