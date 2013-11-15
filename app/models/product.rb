class Product < ActiveRecord::Base
  validates :name, :description, presence: true
end
