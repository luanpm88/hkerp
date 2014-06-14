class SupplierOrderDetail < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  validates :product_id, presence: true
  validates :quantity, presence: true
  validates :price, presence: true
  validates :unit, presence: true
  validates :warranty, presence: true
  
  belongs_to :supplier_order
  belongs_to :product
  
  def total
    price * quantity
  end
  
  def formated_total
    number_to_currency(total, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_price
    number_to_currency(price, precision: 0, unit: '', delimiter: ".")
  end

  def price=(new_price)
    self[:price] = new_price.gsub(/\,/, '')
  end

end
