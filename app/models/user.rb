class User < ActiveRecord::Base
  include PgSearch
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  mount_uploader :image, ImageUploader
  
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
  
  has_many :sales_orders, :class_name => "Order", :foreign_key => "salesperson_id"
  
  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, :to => :ability
  
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
    notifications.where(viewed: 0).order("created_at DESC").limit(20)
  end
  
  def self.backup_system(params)
    dir = Time.now.strftime("%Y_%m_%d_%H%M%S")
    dir += "_db" if !params[:database].nil?
    dir += "_source" if !params[:file].nil?
    
    `mkdir backup` if !File.directory?("backup")    
    `mkdir backup/#{dir}`
    
    backup_cmd = ""
    backup_cmd += "pg_dump -a hkerp_development >> backup/#{dir}/data.dump && " if !params[:database].nil?
    backup_cmd += "cp -a public/uploads backup/#{dir}/ && " if !params[:file].nil?
    backup_cmd += "zip -r backup/#{dir}.zip backup/#{dir} && "
    backup_cmd += "rm -rf backup/#{dir}"
    
    `#{backup_cmd} &`
  end
  
  def commission_statistics(from_date, to_date, params)
    orders = sales_orders.where("order_date >= ? AND order_date <= ?",from_date,to_date)
                        .order("order_date")
    
    if params[:paid_status].present? && params[:paid_status] == "paid"
      orders = orders.where(payment_status_name: "paid")
    end
    if params[:paid_status].present? && params[:paid_status] == "not_paid"
      orders = orders.where("payment_status_name != 'paid'")
    end    
    if params[:customer_id].present?
      orders = orders.where(customer_id: params[:customer_id])
    end
    
    if orders.count == 0
      return []
    end
    
    
    #per month statistics
    data = []
    current_block = {name: orders.first.order_date.strftime("%Y-%m"), data: []}
    
    orders.each do |order|
      month = order.order_date.strftime("%Y-%m")
      if current_block[:name] == month
        current_block[:data] << order
      else
        data << current_block        
        current_block = {name: month, data: []}
      end            
    end
    data << current_block
    
    data_1 = []
    data.each do |block|
      total_sell = 0.00
      block[:data].each do |order|
        total_sell += order.total
      end
      block[:total_sell] = total_sell
      
      data_1 << block
    end
    
    return data_1
  end
  
end
