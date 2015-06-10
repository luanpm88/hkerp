class CommissionProgram < ActiveRecord::Base
  validates :name, presence: true, :uniqueness => true
  validates :interval_type, presence: true
  validates :min_amount, presence: true
  validates :published_at, presence: true
  validates :unpublished_at, presence: true
  validates :description, presence: true
  validates :commission_rate, presence: true
  
  belongs_to :user
  
  def self.all_commission_programs
    order("created_at DESC")
  end
  
  def min_amount=(new_price)
    self[:min_amount] = new_price.to_s.gsub(/\,/, '')
  end
  def max_amount=(new_price)
    self[:max_amount] = new_price.to_s.gsub(/\,/, '')
  end
  
  def start
    if status == 0
      self.update_attribute(:status, 1)
      return true
    else
      return false
    end
  end
  
  def stop
    if status == 1
      self.update_attribute(:status, 0)
      return true
    else
      return false
    end
  end
  
  def self.sales_statistics(user, from_date, to_date, params=nil)
    orders = Order.customer_orders.joins(:order_status).where(order_statuses: {name: ["confirmed","finished"]})
                              .where("order_date >= ? AND order_date <= ?",from_date,to_date)
                              .order("order_date")
    if !user.nil?
      orders = orders.where(salesperson_id: user.id)
    end
    
    if !params.nil?
      if params[:paid_status].present? && params[:paid_status] == "paid"
        orders = orders.where(payment_status_name: "paid")
      end
      if params[:paid_status].present? && params[:paid_status] == "not_paid"
        orders = orders.where("payment_status_name != 'paid'")
      end    
      if params[:customer_id].present?
        orders = orders.where(customer_id: params[:customer_id])
      end
    end  
      
    
    if orders.count == 0
      return nil
    end    
    
    # statistics
    data = {name: "From <strong>#{from_date.strftime("%Y-%m-%d")}</strong> to <strong>#{to_date.strftime("%Y-%m-%d")}</strong>".html_safe,orders: orders}
    
    total_sell = 0.00
    total_commission = 0.00
    
    orders.each do |order|
      total_sell += order.cache_total
      #total_commission += order.commission[:amount]
    end
    data[:total_sell] = total_sell
    
    return data
  end
  
  def self.statistics(user, from_date, to_date, params=nil)
    data = self.sales_statistics(user, from_date, to_date, params=nil)
    
    total = 0.00
    paid = 0.00
    debt = 0.00
    if !data.nil?
      data[:orders].each do |order|
        total += order.commission[:amount].to_f
        paid += order.commissioned_amount
        debt += order.commission_remain
      end
      data[:total] = total
      data[:paid] = paid
      data[:debt] = debt
    end
    
    return data
  end
end
