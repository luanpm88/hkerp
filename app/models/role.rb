class Role < ActiveRecord::Base
  validates :name, presence: true, :uniqueness => true
  
  has_many :assignments, :dependent => :destroy
  has_many :users, :through => :assignments
end
