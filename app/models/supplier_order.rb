class SupplierOrder < ActiveRecord::Base
  validates :supplier_id, presence: true
  
  belongs_to :supplier, :class_name => "Contact"
  belongs_to :tax
  belongs_to :salesperson, :class_name => "User"
  
  has_many :supplier_order_details, :dependent => :destroy
end
