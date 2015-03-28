class PaymentRecord < ActiveRecord::Base
  belongs_to :order
  belongs_to :accountant, :class_name => "User"
  
  validate :valid_amount
  validate :valid_debt_date
  validate :note, presence: true
  
  def valid_amount
    if false
      errors.add(:amount, "too small")
    elsif amount.to_f > order.remain_amount.to_f
      puts amount.to_s+"dddddd"+order.remain_amount.to_s
      errors.add(:amount, "can't be greater than remain amount")
    end
  end
  
  def valid_debt_date
    if order.is_deposited && !debt_date.nil?
      if debt_date <= order.order_date
        errors.add(:debt_date, "can't be smaller than order date")
      end
    end
    
  end
  
  def amount=(new_price)
    self[:amount] = new_price.to_s.gsub(/[\,]/, '').to_f
  end
  
  def amount_formated
    Order.format_price(amount.abs)
  end
  
  def debt_days=(new_amount)
    self[:debt_days] = new_amount.to_s.gsub(/[\,]/, '')
  end
  
  def display_name
    created_at.strftime("%Y-%m-%d")
  end
  
end
