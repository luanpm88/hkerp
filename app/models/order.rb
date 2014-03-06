class Order < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  validates :customer_id, presence: true
  
  belongs_to :customer, :class_name => "Contact"
  #belongs_to :supplier, :class_name => "Contact"
  belongs_to :tax
  
  has_many :order_details
  
  accepts_nested_attributes_for :order_details
  
  def total
    total = 0;
    order_details.each {|item|
      total = total + item.total
    }
    return total*(tax.rate/100+1)
  end
  
  def formated_total
    number_to_currency(total, precision: 0, unit: '', delimiter: ".")
  end
  
end
