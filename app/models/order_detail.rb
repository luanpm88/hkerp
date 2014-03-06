class OrderDetail < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  validates :product_id, presence: true
  validates :supplier_id, presence: true
  validates :unit, presence: true
  validates :supplier_price, presence: true
  validates :price, presence: true
  validates :warranty, presence: true
  validates :quantity, presence: true
  
  belongs_to :order
  belongs_to :product
  belongs_to :supplier, :class_name => "Contact"
  
  def total
    price * quantity
  end
  
  def formated_total
    number_to_currency(total, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_price
    number_to_currency(price, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_supplier_price
    number_to_currency(supplier_price, precision: 0, unit: '', delimiter: ".")
  end
  
end
