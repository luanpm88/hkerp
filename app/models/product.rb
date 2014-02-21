class Product < ActiveRecord::Base
  validates :name, presence: true
  
  has_and_belongs_to_many :categories
  belongs_to :manufacturer
end
