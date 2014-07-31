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
  
  has_many :checkinouts, primary_key: 'ATT_No', foreign_key: 'user_id'
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, :presence => true, :uniqueness => true
  
  def has_role?(role_sym)
    roles.any? { |r| r.name == role_sym }
  end
  
  def name
    if !first_name.nil?
      first_name + " " + last_name
    else
      email.gsub(/@(.+)/,'')
    end
  end
  
  def add_role(role)
    if self.has_role?(role.name)
      return false
    else
      self.roles << role
    end
  end
  
end
