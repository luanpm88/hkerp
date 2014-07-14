class SupplierOrder < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  validates :supplier_id, presence: true
  
  belongs_to :supplier, :class_name => "Contact"
  belongs_to :tax
  belongs_to :salesperson, :class_name => "User"
  
  has_many :supplier_order_details, :dependent => :destroy
  
  def total
    total = 0;
    supplier_order_details.each {|item|
      total = total + item.total
    }
    return total
  end
  
  def total_vat
    return self.total*(tax.rate/100+1)
  end
  
  def vat_amount
    return self.total*(tax.rate/100)
  end
  
  def formated_total
    number_to_currency(self.total, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_total_vat
    number_to_currency(self.total_vat, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_vat_amount
    number_to_currency(self.vat_amount, precision: 0, unit: '', delimiter: ".")
  end

end
