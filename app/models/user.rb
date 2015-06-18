class User < ActiveRecord::Base
  include PgSearch
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  mount_uploader :image, AvatarUploader
  
  has_many :contacts
  has_many :products
  
  has_many :assignments, :dependent => :destroy
  has_many :roles, :through => :assignments
  
  has_many :checkinouts, primary_key: 'ATT_No', foreign_key: 'user_id'
  has_many :checkinout_requests
  has_many :manage_checkinout_requests, :class_name => "CheckinoutRequest", :foreign_key => "manager_id"
  
  has_many :notifications, :dependent => :destroy, :foreign_key => "user_id"
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, :presence => true, :uniqueness => true
  
  has_many :sales_orders, :class_name => "Order", :foreign_key => "salesperson_id"
  has_many :purchase_orders, :class_name => "Order", :foreign_key => "purchaser_id"
  
  has_many :deliveries, foreign_key: 'creator_id'
  has_many :payment_records, foreign_key: 'accountant_id'
  
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
  
  def short_name
    if !first_name.nil?
      first_name + " " + last_name.split(" ").first
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
  
  def avatar_path(version = nil)
    if self.image_url.nil?
      return "public/img/avatar.jpg"
    elsif !version.nil?
      return self.image_url(version)
    else
      return self.image_url
    end
  end
  
  def avatar(version = nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.url_for(controller: "users", action: "avatar", id: self.id, type: version)
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
    backup_cmd += "pg_dump -a hkerp_production >> backup/#{dir}/data.dump && " if !params[:database].nil?
    backup_cmd += "cp -a uploads backup/#{dir}/ && " if !params[:file].nil?
    backup_cmd += "zip -r backup/#{dir}.zip backup/#{dir} && "
    backup_cmd += "rm -rf backup/#{dir}"
    
    `#{backup_cmd} &`
  end

                
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.all
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "users.first_name"
      when "4"
        order = "users.created_at"      
      else
        order = "users.first_name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "users.first_name"
    end
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 5
    @records.each do |item|
      item = [
              link_helper.link_to("<img class=\"avatar-big\" width='60' src='#{item.avatar(:square)}' />".html_safe, {controller: "users", action: "show", id: item.id}, class: "fancybox.ajax fancybox_link main-title"),
              link_helper.link_to(item.name, {controller: "users", action: "show", id: item.id}, class: "fancybox.ajax fancybox_link main-title")+item.quick_info,
              '<div class="text-center">'+item.roles_name+"</div>",
              '<div class="text-center">'+item.ATT_No.to_s+"</div>",
              '<div class="text-center">'+item.created_at.strftime("%Y-%m-%d")+"</div>", 
              '',
            ]
      data << item
      
    end
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: @records, actions_col: actions_col}
    
  end
  
  def roles_name
    names = []
    roles.order("name").each do |r|
      names << "<span class=\"badge badge-info #{r.name}\">#{r.name}</span>"
    end
    return names.join("<br />").html_safe
  end
  
  def quick_info
    info = email
    info += "<br />Mobile: #{mobile}" if mobile.present?
    
    return info.html_safe
  end
  
  def activity_log(from_date, to_date)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    history = []
    
    import_icon = '<i class="icon-download-alt"></i> '.html_safe
    export_icon = '<i class="icon-external-link"></i> '.html_safe
    #Order details, sales and purchases
    s_orders = sales_orders.where('orders.order_date >= ?', from_date)
                      .where('orders.order_date <= ?', to_date)
    p_orders = purchase_orders.where('orders.order_date >= ?', from_date)
                      .where('orders.order_date <= ?', to_date)
    
    orders = s_orders + p_orders
    
    orders.each do |o|
      if o.parent.nil?
        action = "Created"
        order_link = o.first_order.order_link
      else
        action = "Updated"
        order_link = o.next_order.order_link
      end
      
      order_type = o.is_purchase ? "purchase" : "sales"
      
      to_from = o.is_purchase ? "order to [#{o.supplier.name}]" : "order from [#{o.customer.name}]"
      
      current_status = "[<span class=\"#{o.first_order.order_status_name}\">#{o.first_order.order_status_name}</span>]"
      
      next_status = ""
      if !o.next_order.nil?
        next_status = " => [<span class=\"#{o.next_order.order_status_name}\">#{o.next_order.order_status_name}</span>]"
      end
      
      line = {user: self, date: o.created_at, note: "#{action} #{order_type} #{to_from}<br />status: #{current_status}#{next_status}", link: order_link, quantity: nil}

      history << line
    end
    
    #Deliveries
    ds = deliveries.where('deliveries.created_at >= ?', from_date)
                  .where('deliveries.created_at <= ?', to_date)
       
    ds.each do |d|
      quantity = d.delivery_details.count(:quantity)
      
      if d.order.is_purchase
        action = "Recieved"
        to_from = "from supplier [#{d.order.supplier.name}]"        
        icon = import_icon
        
        if d.is_return == 1
          action = "Returned"
          to_from = "to supplier [#{d.order.supplier.name}]"        
          icon = export_icon
        end
        
      else
        action = "Delivered"
        to_from = "to customer [#{d.order.customer.name}]"        
        icon = export_icon
        
        if d.is_return == 1
          action = "Recieved Returned"
          to_from = "from customer [#{d.order.supplier.name}]"        
          icon = import_icon
        end
      end
      
      
      line = {user: d.creator, date: d.created_at, note: "#{action} items #{to_from}", link: d.delivery_link, quantity: icon+quantity.to_s}
      
      history << line
    end
    
    #Deliveries
    ps = payment_records.where('payment_records.created_at >= ?', from_date)
                  .where('payment_records.created_at <= ?', to_date)
       
    ps.each do |p|
  
      if p.type_name == "order" || p.type_name == "tip"  || p.type_name == "commission"
        if p.order.is_purchase
          action = "Paid #{p.type_name}"
          to_from = "to supplier [#{p.order.supplier.name}]"        
          icon = export_icon
          
          if p.amount < 0
            action = "Recieved back #{p.type_name}"
            to_from = "from supplier [#{p.order.supplier.name}]"        
            icon = import_icon
          end
          
        else
          action = "Recieved #{p.type_name}"
          to_from = "from customer [#{p.order.customer.name}]"        
          icon = import_icon
          
          if p.amount < 0
            action = "Paid back #{p.type_name}"
            to_from = "to customer [#{p.order.customer.name}]"        
            icon = export_icon
          end
        end
      end
      
      if p.type_name == "custom"
        if p.amount < 0
          action = "Custom Paid"
          to_from = ""        
          icon = export_icon
        else
          action = "Custom Recieved"
          to_from = ""        
          icon = import_icon
        end
      end
        
      
      
      line = {user: p.accountant, date: p.created_at, note: "#{action} payment #{to_from}", link: p.payment_record_link, quantity: icon+ApplicationController.helpers.format_price(p.amount.abs)}
      
      history << line
    end
    
    
    
    return history.sort {|a,b| b[:date] <=> a[:date]}
  end
  
  def staff_col
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.link_to("<img class=\"round-ava\" src=\"#{self.avatar(:square)}\" width=\"35\" /><br /><span class=\"user-name\" />#{self.short_name}</span>".html_safe, {controller: "users", action: "show", id: self.id}, title: self.name, class: "fancybox.ajax fancybox_link")
  end
  
end
