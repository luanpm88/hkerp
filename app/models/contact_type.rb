class ContactType < ActiveRecord::Base
  validates :name, :presence => true
  
  has_many :contacts
  
  def self.customer
    self.find_by_name('Customer').id.to_s
  end
  
  def self.supplier
    self.find_by_name('Supplier').id.to_s
  end
  
end
