class ParentContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :parent, :class_name => "Contact"  
end
