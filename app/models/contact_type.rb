class ContactType < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  
  has_and_belongs_to_many :contacts
  
  def self.customer
    self.find_by_name('Customer').id.to_s
  end
  
  def self.supplier
    self.find_by_name('Supplier').id.to_s
  end
  
  def self.agent
    self.find_by_name('Agent').id.to_s
  end
  
end
