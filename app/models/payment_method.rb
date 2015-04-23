class PaymentMethod < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  
  has_many :orders
  has_many :payment_records
  
  def all_payments
    order("created_at DESC")
  end
end
