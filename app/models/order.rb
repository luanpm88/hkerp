class Order < ActiveRecord::Base
  
  belongs_to :customer, :class_name => "Contact"
  belongs_to :supplier, :class_name => "Contact"
end
