class PaymentRecord < ActiveRecord::Base
  belongs_to :order
  belongs_to :accountant, :class_name => "User"
  belongs_to :payment_method
  belongs_to :user
  
  validates :note, presence: true
  validates :payment_method, presence: true
  validates :amount, presence: true
  
  validate :valid_amount
  validate :valid_debt_date
  
  after_save :update_payment_status_name
  
  def self.all_records
    where(status: 1).where(is_tip: false).where(is_custom: false)
  end
  
  def self.custom_records
    PaymentRecord.where(is_custom: true)
  end
  
  def self.datatable(params)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    
    @records = PaymentRecord.custom_records.order("paid_date DESC, created_at DESC")

    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 4
    @records.each do |item|
      
      item = [
              item.note,
              item.is_recieved ? '<div class="text-right">'+ApplicationController.helpers.format_price(item.amount).to_s+'</div>' : "",
              !item.is_recieved ? '<div class="text-right">'+ApplicationController.helpers.format_price(item.amount).to_s+'</div>' : "",
              '<div class="text-center">'+item.paid_date.strftime("%Y-%m-%d")+'</div>',
              "1",
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
  
  def update_payment_status_name
    if !order.nil?
      order.update_payment_status_name
      order.update_tip_status_name
    end
  end
  
  def valid_amount
    if !is_tip && !is_custom
      if !order.is_payback && amount.to_f > order.remain_amount.to_f.round(2)
        errors.add(:amount, "can't be greater than remain amount")
      end
      if order.is_payback && amount.to_f > order.remain_amount.to_f.abs.round(2)
        errors.add(:amount, "can't be greater than remain amount")
      end
    end
    
    if is_tip
      if order.tip_amount.to_f.round(2) != amount.to_f
        errors.add(:amount, "not valid")
      end
    end
  end
  
  def valid_debt_date
    if !is_tip && !is_custom
      if order.is_deposited && !debt_date.nil?
        if debt_date <= order.order_date
          errors.add(:debt_date, "can't be smaller than order date")
        end
      end
    end
  end
  
  def amount=(new_price)
    self[:amount] = new_price.to_s.gsub(/[\,]/, '').to_f
  end
  
  def amount_formated
    Order.format_price(amount.abs)
  end
  
  def debt_days=(new_amount)
    self[:debt_days] = new_amount.to_s.gsub(/[\,]/, '')
  end
  
  def display_name
    created_at.strftime("%Y-%m-%d")
  end
  
  def payment_record_link
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    link_helper.link_to("<i class=\"icon-print\"></i>".html_safe+" Recept ("+self.created_at.strftime("%Y-%m-%d")+")", {controller: "payment_records", action: "show", id: self.id}, :class => 'fancybox.iframe ajax_iframe').html_safe
  end
  
  def trash
    self.update_attribute(:status, 0)
  end
  
  def self.statistics(from_date, to_date, params)
    records = PaymentRecord.where(status: 1).where("paid_date >= ? AND paid_date <= ?", from_date.beginning_of_day, to_date.end_of_day).order("paid_date DESC, created_at DESC")
    
    if params[:payment_method_id].present?
      records = records.where(payment_method_id: params[:payment_method_id])
    end
    
    
    total_pay = 0.00
    total_recieve = 0.00
    
    datas = []    
    records.each do |p|
      data = {payment_record: p,pay: "", recieve: ""}
      if p.is_tip
         total_pay += p.amount
         data[:pay] = p.amount
      elsif p.is_custom
        if p.is_recieved
          total_recieve += p.amount
          data[:recieve] = p.amount
        else
          total_pay += p.amount
          data[:pay] = p.amount
        end
      else
        if p.order.is_purchase || (!p.order.is_purchase && p.amount < 0)
          total_pay += p.amount.abs
          data[:pay] = p.amount.abs
        elsif
          total_recieve += p.amount.abs
          data[:recieve] = p.amount.abs
        end
      end
      
      datas << data
    end
    
    return {datas: datas, total_pay: total_pay, total_recieve: total_recieve}
  end
  
end
