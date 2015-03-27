class User < ActiveRecord::Base
  include PgSearch
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  mount_uploader :image, ImageUploader
  
  
  has_many :sale_orders, :class_name => "Order"
  has_many :contacts
  has_many :products
  
  has_many :assignments
  has_many :roles, :through => :assignments
  
  has_many :checkinouts, primary_key: 'ATT_No', foreign_key: 'user_id'
  has_many :checkinout_requests
  has_many :manage_checkinout_requests, :class_name => "CheckinoutRequest", :foreign_key => "manager_id"
  
  has_many :notifications, :dependent => :destroy, :foreign_key => "user_id"
  
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
  
  def work_time_by_month(month, year)
    return (Checkinout.get_work_time_by_month(self, month, year)/3600).round(2).to_s
  end
  
  def addition_time(month, year)
    return ((Checkinout.get_work_time_by_month(self, month, year)/3600).round(2)-Checkinout.default_hours_per_month)
  end
  
  def addition_time_formatted(month, year)
    add_time = self.addition_time(month, year).round(2)
    if add_time < 0
      return "<span class='red'>"+add_time.to_s+"</span>"
    else
      return "<span class='green'>"+add_time.to_s+"</span>"
    end    
  end
  
  def checkinouts_by_month(month, year)
    time_string = year.to_s+"-"+month.to_s
    checks = []
    (1..31).each do |i|
      time = Time.zone.parse(time_string+"-"+i.to_s)
      if time.strftime("%m").to_i == month && time.wday != 0
        esxit = Checkinout.where(user_id: self.ATT_No, check_date: time.to_date)
        if esxit.count > 0
          checks << esxit.first        
        end
      end      
    end
    return checks
  end
  
  def avatar(version = nil)
    if self.image_url.nil?
      return "/img/avatar.jpg"
    elsif !version.nil?
      return self.image_url(version)
    else
      return self.image_url
    end
  end  
  
  def self.current_user
    Thread.current[:current_user]
  end
  
  pg_search_scope :search,
                against: [:first_name, :last_name],                
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.full_text_search(q)
    self.search(q).limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
  
  def notification_unread_count
    notifications.where(viewed: 0).count
  end
  
  def notification_top
    notifications.order("created_at DESC").limit(20)
  end
  
end
