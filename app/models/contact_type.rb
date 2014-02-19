class ContactType < ActiveRecord::Base
  has_many :contacts
  
  def self.customer
    1.to_s
  end
  
  def self.supplier
    2.to_s
  end
  
end
