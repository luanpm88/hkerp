class PaymentRecord < ActiveRecord::Base
  belongs_to :order
  belongs_to :accountant, :class_name => "User"
  belongs_to :payment_method
  belongs_to :user
  
  validates :note, presence: true
  validates :payment_method, presence: true
  
  validate :valid_amount
  validate :valid_debt_date
  
  after_save :update_payment_status_name
  
  def self.all_records
    where(status: 1).where(is_tip: false)
  end
  
  def update_payment_status_name
    order.update_payment_status_name
    order.update_tip_status_name
  end
  
  
  def all_payment_records
    where(is_tip: false)
  end
  
  def valid_amount
    if !is_tip       
      if false
        errors.add(:amount, "too small")
      end
      if !order.is_payback && amount.to_f > order.remain_amount.to_f.round(2)
        errors.add(:amount, "can't be greater than remain amount")
      end
      if order.is_payback && amount.to_f > order.remain_amount.to_f.abs.round(2)
        errors.add(:amount, "can't be greater than remain amount")
      end
    else
      if order.tip_amount.to_f.round(2) != amount.to_f
        errors.add(:amount, "not valid")
      end
    end
  end
  
  def valid_debt_date
    if !is_tip
      if order.is_deposited && !debt_date.nil?
        if debt_date <= order.order_date
          errors.add(:debt_date, "can't be smaller than order date")
        end
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
  
  def payment_record_link
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    link_helper.link_to("<i class=\"icon-print\"></i>".html_safe+" Recept ("+self.created_at.strftime("%Y-%m-%d")+")", {controller: "payment_records", action: "show", id: self.id}, :class => 'fancybox.iframe ajax_iframe').html_safe
  end
  
  def trash
    self.update_attribute(:status, 0)
  end
  
end
