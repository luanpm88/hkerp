class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :sale_orders, :class_name => "Order"
  has_many :contacts
  has_many :products
  
  has_many :assignments
  has_many :roles, :through => :assignments
  
  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end
  
  def name
    if !first_name.nil?
      first_name + " " + last_name
    else
      email.gsub(/@(.+)/,'')
    end
  end
  
end
