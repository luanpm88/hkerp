class OrderStatus < ActiveRecord::Base
  validates :name, presence: true, :uniqueness => true
  
  has_many :orders
end
