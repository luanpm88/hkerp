class PaymentRecord < ActiveRecord::Base
  belongs_to :order
  belongs_to :accountant, :class_name => "User"
  belongs_to :payment_method
  belongs_to :user
  belongs_to :bank_account

  
  validates :note, presence: true
  validates :payment_method, presence: true
  validates :amount, presence: true
  
  validates :type_name, presence: true
  
  
  validate :valid_amount
  validate :valid_debt_date
  
  after_save :update_order_status_names
  after_destroy :update_order_status_names
  
  def self.all_order_payments
    self.where(type_name: 'order')
            .where(status: 1)
            .order("created_at DESC")
  end
  
  def self.custom_records
    self.where(type_name: 'custom')
        .where(status: 1)
        .order("created_at DESC")
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
              !item.is_paid ? '<div class="text-right">'+ApplicationController.helpers.format_price(item.amount).to_s+'</div>' : "",
              item.is_paid ? '<div class="text-right">'+ApplicationController.helpers.format_price(item.amount.abs).to_s+'</div>' : "",
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
  
  def update_order_status_names
    if !order.nil?
      order.update_status_names
    end
  end
  
  def valid_amount
    if type_name == 'order'
      if !order.is_payback && amount.to_f > order.remain_amount.to_f.round(2)
        errors.add(:amount, "can't be greater than remain amount")
      end
      if order.is_payback && amount.to_f > order.remain_amount.to_f.abs.round(2)
        errors.add(:amount, "can't be greater than remain amount")
      end
    end
    
    if type_name == 'tip'
      if order.remain_tip != amount.to_f
        errors.add(:amount, "not valid")
      end
    end
  end
  
  def valid_debt_date
    if type_name == 'order'
      if order.is_deposited && !debt_date.nil?
        if debt_date < order.order_date.beginning_of_day
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
  
  def tax_amount
    if order.present?
      return amount - amount_without_tax
    end
    return 0
  end
  
  def tax_formated
    if order.present?
      return Order.format_price(tax_amount)
    end
    
    return ''
  end
  
  def amount_without_tax
    if order.present?
      return (amount / (1+(order.tax.rate/100)))
    end
    
    return 0
  end
  
  def amount_without_tax_formated
    if order.present?
      return Order.format_price(amount_without_tax)
    end
    
    return ''
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
    link_helper.link_to("<i class=\"icon-print\"></i>".html_safe+" Recept ("+self.created_at.strftime("%Y-%m-%d")+")", {controller: "payment_records", action: "show", id: self.id, tab_page: 1}, :class => 'tab_page', title: "Recept [#{created_at.strftime("%Y-%m-%d")}]").html_safe
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
      if p.type_name == 'tip' || p.type_name == 'commission'
         total_pay += p.amount
         data[:pay] = p.amount
      elsif p.type_name == 'custom'
        if !p.is_paid
          total_recieve += p.amount
          data[:recieve] = p.amount
        else
          total_pay += p.amount.abs
          data[:pay] = p.amount.abs
        end
      elsif p.type_name == 'order'
        if p.order.is_purchase || (!p.order.is_purchase && p.amount < 0)
          total_pay += p.amount.abs
          data[:pay] = p.amount.abs
        elsif !p.order.is_purchase || (p.order.is_purchase && p.amount < 0)
          total_recieve += p.amount.abs
          data[:recieve] = p.amount.abs
        end
      end
      
      datas << data
    end
    
    return {
      datas: datas,
      total_pay: total_pay,
      total_recieve: total_recieve,
      begin: PaymentRecord.remain(
        to_date: (from_date - 1.day).end_of_day,
        bank_account_id: params[:bank_account_id],
      ),
      end: PaymentRecord.remain(
        to_date: to_date.end_of_day,
        bank_account_id: params[:bank_account_id]
      ),
    }
  end
  
  def self.cash_book(from_date, to_date, params)
    records = PaymentRecord.includes(:bank_account).where(status: 1).where(bank_accounts: {name: "Cash"})
                            .where("payment_records.paid_date >= ? AND payment_records.paid_date <= ?", from_date.beginning_of_day, to_date.end_of_day)
                            .order("payment_records.paid_date DESC, payment_records.created_at DESC")
    
    if params[:payment_method_id].present?
      records = records.where(payment_method_id: params[:payment_method_id])
    end
    
    
    total_pay = 0.00
    total_recieve = 0.00
    
    datas = []    
    records.each do |p|
      data = {payment_record: p,pay: "", recieve: ""}
      if p.type_name == 'tip' || p.type_name == 'commission'
         total_pay += p.amount
         data[:pay] = p.amount
      elsif p.type_name == 'custom'
        if !p.is_paid
          total_recieve += p.amount
          data[:recieve] = p.amount
        else
          total_pay += p.amount.abs
          data[:pay] = p.amount.abs
        end
      elsif p.type_name == 'order'
        if p.order.is_purchase || (!p.order.is_purchase && p.amount < 0)
          total_pay += p.amount.abs
          data[:pay] = p.amount.abs
        elsif !p.order.is_purchase || (p.order.is_purchase && p.amount < 0)
          total_recieve += p.amount.abs
          data[:recieve] = p.amount.abs
        end
      end
      
      datas << data
    end
    
    
    cash_account = BankAccount.where(name: "Cash").first
    return {
      datas: datas,
      total_pay: total_pay,
      total_recieve: total_recieve,
      begin: PaymentRecord.remain(
        to_date: (from_date - 1.day).end_of_day,
        bank_account_id: cash_account.id,
      ),
      end: PaymentRecord.remain(
        from_date: to_date.end_of_day,
        bank_account_id: cash_account.id
      ),
    }
  end
  
  def self.account_book(from_date, to_date, params)
    records = PaymentRecord.includes(:bank_account).where(status: 1)
                            .where("payment_records.paid_date >= ? AND payment_records.paid_date <= ?", from_date.beginning_of_day, to_date.end_of_day)
                            .order("payment_records.paid_date DESC, payment_records.created_at DESC")
    
    if params[:payment_method_id].present?
      records = records.where(payment_method_id: params[:payment_method_id])
    end
    
    if params[:bank_account_id].present?
      records = records.where(bank_account_id: params[:bank_account_id])
    end
    
    total_pay = 0.00
    total_recieve = 0.00
    
    datas = []    
    records.each do |p|
      data = {payment_record: p,pay: "", recieve: ""}
      if p.type_name == 'tip' || p.type_name == 'commission'
         total_pay += p.amount
         data[:pay] = p.amount
      elsif p.type_name == 'custom'
        if !p.is_paid
          total_recieve += p.amount
          data[:recieve] = p.amount
        else
          total_pay += p.amount.abs
          data[:pay] = p.amount.abs
        end
      elsif p.type_name == 'order'
        if p.order.is_purchase || (!p.order.is_purchase && p.amount < 0)
          total_pay += p.amount.abs
          data[:pay] = p.amount.abs
        elsif !p.order.is_purchase || (p.order.is_purchase && p.amount < 0)
          total_recieve += p.amount.abs
          data[:recieve] = p.amount.abs
        end
      end
      
      datas << data
    end
    
    
    
    return {
      datas: datas,
      total_pay: total_pay,
      total_recieve: total_recieve,
      begin: PaymentRecord.remain(
        to_date: (from_date - 1.day).end_of_day,
        bank_account_id: params[:bank_account_id],
      ),
      end: PaymentRecord.remain(
        to_date: to_date.end_of_day,
        bank_account_id: params[:bank_account_id]
      ),
    }
  end
  
  def is_paid
    (type_name == "custom" && amount < 0) || (type_name == "commission" && amount > 0) || (type_name == "tip" && amount > 0) || ((type_name == "order" && order.is_purchase && amount > 0) || (type_name == "order" && !order.is_purchase && amount < 0))
  end
  
  def self.total_cash(options={})
    result = 0.0
    query = PaymentRecord.includes(:bank_account, :order).where(status: 1).where(bank_accounts: {name: "Cash"})
    
    if options[:to_date].present?
      query = query.where("paid_date <= ?", options[:to_date].end_of_day)
    end
    
    # tip / commission
    result -= query.where(type_name: ["tip","commission"])
                            .sum(:amount).abs
    
    # custom payment
    result += query.where(type_name: ["custom"])
                            .sum(:amount)
                            
    # purchase
    result -= query.where(orders: {customer_id: Contact.HK.id})
                            .where(type_name: ["order"])
                            .sum(:amount)
    
    # sales
    result += query.where(orders: {supplier_id: Contact.HK.id})
                            .where(type_name: ["order"])
                            .sum(:amount)
  end
  
  def self.remain(options={})
    result = 0.0
    query = PaymentRecord.includes(:bank_account, :order).where(status: 1)
    
    if options[:to_date].present?
      query = query.where("paid_date <= ?", options[:to_date].end_of_day)
    end
    
    if options[:bank_account_id].present?
      query = query.where(bank_account_id: options[:bank_account_id])
    end
    
    # tip / commission
    result -= query.where(type_name: ["tip","commission"])
                            .sum(:amount).abs
    
    # custom payment
    result += query.where(type_name: ["custom"])
                            .sum(:amount)
                            
    # purchase
    result -= query.where(orders: {customer_id: Contact.HK.id})
                            .where(type_name: ["order"])
                            .sum(:amount)
    
    # sales
    result += query.where(orders: {supplier_id: Contact.HK.id})
                            .where(type_name: ["order"])
                            .sum(:amount)
  end
  
  def description
    str = []
    if self.type_name == 'tip'
      str << 'Pay tip'
      str << "[#{self.order.quotation_code}]"
    elsif self.type_name == 'commission'
      str << 'Pay commission'
      str << "[#{self.order.salesperson.name}]"
    elsif self.type_name == 'custom'
      str << 'Custom'
    elsif self.type_name == 'order'
      str << (self.order.is_purchase ? "Purchase" : "Sales")
      str << 'Order'
      if self.amount < 0
        str << '[Pay back]'
      end
    end
    return str.join(" ")
  end
  
  def printed_order_number
    if self.type_name == 'order' || self.type_name == 'commission' || self.type_name == 'tip'
      if self.order.printed_order_number.present?
        self.order.printed_order_number
      end
    end
  end
  
end
