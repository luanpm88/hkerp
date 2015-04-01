class PaymentRecord < ActiveRecord::Base
  belongs_to :order
  belongs_to :accountant, :class_name => "User"
  belongs_to :payment_method
  
  validates :note, presence: true
  validates :payment_method, presence: true
  
  validate :valid_amount
  validate :valid_debt_date
  
  
  def valid_amount
    if false
      errors.add(:amount, "too small")
    end
    if !order.is_payback && amount.to_f > order.remain_amount.to_f.round(0)
      errors.add(:amount, "can't be greater than remain amount")
    end
    if order.is_payback && amount.to_f > order.remain_amount.to_f.abs.round(0)
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
