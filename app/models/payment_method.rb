class PaymentMethod < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  
  has_many :orders
  has_many :payment_records
end
