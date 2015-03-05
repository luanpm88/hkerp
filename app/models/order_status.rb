class OrderStatus < ActiveRecord::Base
  validates :name, presence: true, :uniqueness => true
  
  has_and_belongs_to_many :orders
  
  def self.get(name)
    return where(name: name).first
  end
end
