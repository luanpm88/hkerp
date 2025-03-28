class Order < ActiveRecord::Base
  include PgSearch

  after_save :update_cache_search

  attr_accessor :debt_days

  validates :supplier_id, presence: true
  validates :customer_id, presence: true
  validates :order_date, presence: true
  validates :order_deadline, presence: true
  validate :valid_debt_date
  #validate :valid_discount
  #validate :valid_tip

  belongs_to :customer, :class_name => "Contact"
  belongs_to :supplier, :class_name => "Contact"
  # belongs_to :tax
  belongs_to :payment_method
  belongs_to :salesperson, :class_name => "User"
  belongs_to :purchase_manager, :class_name => "User"
  belongs_to :purchaser, :class_name => "User"

  belongs_to :user

  belongs_to :tip_contact, :class_name => "Contact"
  belongs_to :shipment_contact, :class_name => "Contact"

  has_many :order_details, :dependent => :destroy

  has_many :drafts, class_name: "Order", foreign_key: "parent_id", :dependent => :destroy
  belongs_to :parent, class_name: "Order"

  has_and_belongs_to_many :order_statuses
  belongs_to :order_status

  #has_one :order_statuses_order, -> { order created_at: :desc }
  #belongs_to :order_status, :through => :order_statuses_order

  has_many :deliveries, :dependent => :destroy

  has_many :payment_records, :dependent => :destroy

  has_many :notifications, foreign_key: "item_id", :dependent => :destroy

  after_save :update_status_names


  def valid_debt_date
    if !deposit.nil? && deposit > 0 && !debt_date.nil?
        if debt_date <= order_date
            errors.add(:debt_date, "can't be smaller than order date")
        end
    end
  end

  def total
    total = 0;
    order_details.each {|item|
      total = total + item.total
    }
    return total
  end

  def total_vat
    # sum = self.total*(tax.rate/100+1)
    sum = 0;
    order_details.each {|item|
      sum = sum + item.total_vat
    }
    return sum.round(2)
  end

  def vat_amount
    total = 0;
    order_details.each {|item|
      total = total + item.vat_amount
    }
    return total
  end

  def vat_amount_formated
    Order.format_price(vat_amount)
  end

  def self.format_price(amount)
    return ApplicationController.helpers.format_price(amount)
  end

  def formated_total
    Order.format_price(total)
  end

  def formated_total_vat
    Order.format_price(total_vat)
  end

  def formated_vat_amount
    Order.format_price(vat_amount)
  end

  def formated_warranty_cost
    Order.format_price(warranty_cost)
  end

  def warranty_cost=(new_warranty_cost)
    self[:warranty_cost] = new_warranty_cost.gsub(/\,/, '')
  end

  def create_quotation_code
    lastest = Order.where("order_date::text LIKE :val", :val => order_date.strftime("%Y")+"-"+order_date.strftime("%m")+"%")
        .where(parent_id: nil)
        .order("quotation_code DESC").first

    if !lastest.nil? && !lastest.quotation_code.nil?
      num = lastest.quotation_code.split(/\-/).last.to_i + 1
      self.quotation_code = "HK-"+order_date.strftime("%Y")+order_date.strftime("%m")+"-"+num.to_s.rjust(3, '0')
    else
      self.quotation_code = "HK-"+order_date.strftime("%Y")+order_date.strftime("%m")+"-"+1.to_s.rjust(3, '0')
    end
  end

  def clone_order
    new_order = self.dup
    new_order.order_details << self.order_details.collect { |item| item.dup }

    return new_order
  end

  def new_order_history
    new_order = self.clone_order
    new_order.older = self

    new_order.create_quotation_code

    new_order.save

    return new_order
  end

  def order_history_lines_
    arr = []
    current = self
    arr << current
    while !(current = current.older).nil?
      arr << current
    end

    current = self.newer
    if !current.nil?
      arr.unshift(current)
      while !(current = current.newer).nil?
        arr.unshift(current)
      end
    end

    return arr
  end

  def order_history_lines
    arr = []
    parent = self.parent.nil? ? self : self.parent
    arr << parent

    parent.drafts.order("created_at DESC").each do |o|
      arr << o
    end

    return arr
  end

  @@mangso = ["không","một","hai","ba","bốn","năm","sáu","bảy","tám","chín"]
  def dochangchuc(so,daydu)
    chuoi = ""
    chuc = (so/10).to_i
    donvi = so%10

    if chuc > 1
      chuoi = " " + @@mangso[chuc] + " mươi";
      if donvi == 1
        chuoi += " mốt"
      end
    elsif chuc==1
      chuoi = " mười"
      if donvi==1
        chuoi += " một"
      end
    elsif daydu && donvi>0
      chuoi = " lẻ"
    end

    if donvi==5 && chuc>1
      chuoi += " lăm"
    elsif donvi>1 || (donvi==1 && chuc==0)
        chuoi += " " + @@mangso[donvi]
    end
    return chuoi
  end

  def docblock(so,daydu)
    chuoi = ""
    tram = (so/100).floor
    so = so%100
    if daydu || tram>0
      chuoi = " " + @@mangso[tram] + " trăm"
      chuoi += dochangchuc(so,true)
    else
      chuoi = dochangchuc(so,false)
    end
    return chuoi;
  end

  def dochangtrieu(so,daydu)
    chuoi = ""
    trieu = (so/1000000).floor
    so = so%1000000
    if trieu>0

      chuoi = docblock(trieu,daydu) + " triệu"
      daydu = true
    end
    nghin = (so/1000).floor
    so = so%1000;
    if nghin>0
        chuoi += docblock(nghin,daydu) + " nghìn";
        daydu = true;
    end
    if so>0
        chuoi += docblock(so,daydu)
    end
    return chuoi
  end

  def docso(so)
    return @@mangso[0] if so==0
    chuoi = ""
    hauto = ""
    begin
      ty = so%1000000000
      so = (so/1000000000).floor
      if so>0
        chuoi = dochangtrieu(ty,true) + hauto + chuoi
      else
        chuoi = dochangtrieu(ty,false) + hauto + chuoi
      end
      hauto = " tỷ"
    end while so>0

    chuoi = chuoi.strip.capitalize
    chuoi = (chuoi =~ /Triệu/) == 0 ? "Một " + chuoi : chuoi
    chuoi = (chuoi =~ /Tỷ/) == 0 ? "Một " + chuoi : chuoi
    chuoi = (chuoi =~ /Nghìn/) == 0 ? "Một " + chuoi : chuoi

    return chuoi.strip.capitalize + " đồng"
  end

  def status
    if self.order_status.present?
      return self.order_status
    else
      OrderStatus.where(name: 'new').first
    end
  end

  def status_formatted
    if self.status.nil?
    else
      self.status.description
    end
  end

  def set_status(name,user=nil)
    status = OrderStatus.where(name: name).first
    if status.nil?
      return false
    else
      self.order_statuses << status
      self.order_status = status
      self.save

      oso = OrderStatusesOrder.where(order_id: self.id).where(order_status_id: status.id).order("created_at DESC").first
      oso.update_attributes(user_id: user.id)

    end

    self.update_status_names

    return status
  end

  def last_updated
    if self.status.nil?
      return self.updated_at
    else
      self.status.updated_at
    end
  end

  def last_updated_formatted
    self.last_updated.strftime("%Y-%m-%d, %H:%M")
  end

  def order_date_formatted
    self.order_date.strftime("%Y-%m-%d")
  end

  def confirm_order(user)
    if order_details.count == 0
      return false
    end

    # Update product price
    order_details.each do |od|
      pp = od.update_price(user, true)
      od.update_attribute(:product_price_id, pp.id) if !pp.nil?
    end

    self.set_status('confirmed',user)
    Notification.send_notification(salesperson, 'order_confirmed', self)

    return true
  end

  def cancel_order(user)

    self.set_status('canceled',user)
    # Notification.send_notification(salesperson, 'order_canceled', self)

    return true
  end

  def finish_order(user)
    if !printed_order_number.present?
      return false
    end

    self.set_status('finished',user)

    return true
  end

  def confirm_items(user)
    if order_details.count == 0
      return false
    end

    self.set_status('items_confirmed',user)
    Notification.send_notification(salesperson, 'order_items_confirmed', self)

    return true
  end

  def self.customer_orders
    order("order_date DESC").where("supplier_id="+Contact.HK.id.to_s)
                            .where(parent_id: nil)
  end

  def self.purchase_orders
    order("order_date DESC").where("customer_id="+Contact.HK.id.to_s)
                            .where(parent_id: nil)
  end

  def is_purchase
    return self.customer == Contact.HK
  end

  def is_sales
    return self.supplier == Contact.HK
  end

  def self.statistics(from_date, to_date, params = {})
    total_buy = 0.00
    total_sell = 0.00
    total_buy_with_vat = 0.00
    total_sell_with_vat = 0.00
    total_vat_buy = 0.00
    total_vat_sell = 0.00
    payment_paid = 0.00
    payment_paid_vat = 0.00
    payment_recieved = 0.00
    payment_recieved_vat = 0.00
    payment_vat_paid = 0.00
    payment_vat_recieved = 0.00

    total_buy_with_vat_notpaid = 0.00
    total_sell_with_vat_notpaid = 0.00
    total_buy_with_vat_paid = 0.00
    total_sell_with_vat_paid = 0.00

    total_tip_amount_notpaid = 0.00
    total_tip_amount_paid = 0.00

    total_PAD_buy_paid = 0.00
    total_PAD_sell_paid = 0.00

    total_fare = 0.00
    total_cost = 0.00

    sell_orders = Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: "finished"})

    if params[:paid_date_check].present? && params[:paid_date_filter].present?
      paid_date = params[:paid_date_filter].to_date
      payments = PaymentRecord.all_order_payments.where('paid_date >= ?', paid_date.beginning_of_day)
                                          .where('paid_date <= ?', paid_date.end_of_day)
      if params[:customer_id].present?
        payments = payments.joins(:order).where(orders: {customer_id: params[:customer_id]})
      end

      payments.each do |p|
        total_PAD_sell_paid += p.amount
      end

      order_ids = payments.map(&:order_id)
      sell_orders = sell_orders.where(id: order_ids)
    else
      sell_orders = sell_orders.where('order_date >= ?', from_date.beginning_of_day)
                                .where('order_date <= ?', to_date.end_of_day)
    end


    if params[:customer_id].present?
      sell_orders = sell_orders.where(customer_id: params[:customer_id])
    end
    if params[:tip_contact_id].present?
      sell_orders = sell_orders.where(tip_contact_id: params[:tip_contact_id])
    end
    if params[:paid_status].present? && params[:paid_status] == "paid"
      sell_orders = sell_orders.where(payment_status_name: "paid")
    end
    if params[:paid_status].present? && params[:paid_status] == "not_paid"
      sell_orders = sell_orders.where("payment_status_name != 'paid'")
    end
    if params[:paid_status].present? && params[:paid_status] == "out_of_date"
      sell_orders = sell_orders.where(payment_status_name: 'out_of_date')
    end


    sell_orders.each do |order|
      if order.parent.nil?
        total_sell += order.total
        total_sell_with_vat += order.total_vat
        total_vat_sell += order.vat_amount

        payment_recieved_vat += order.paid_amount
        payment_recieved += order.paid_amount - order.vat_amount
        #payment_vat_recieved += order.paid_amount*(order.tax.rate/100)

        total_sell_with_vat_notpaid += order.remain_amount
        total_sell_with_vat_paid += order.paid_amount

        total_tip_amount_notpaid += order.tip_amount if !order.is_tipped
        total_tip_amount_paid += order.tip_amount if order.is_tipped

        total_fare += order.fare
        total_cost += order.cost
      end
    end

    buy_orders = Order.purchase_orders
                  .joins(:order_status).where(order_statuses: {name: "finished"})

    if params[:paid_date_check].present? && params[:paid_date_filter].present?
      paid_date = params[:paid_date_filter].to_date
      payments = PaymentRecord.all_order_payments.where('paid_date >= ?', paid_date.beginning_of_day)
                                          .where('paid_date <= ?', paid_date.end_of_day)
      if params[:supplier_id].present?
        payments = payments.joins(:order).where(orders: {supplier_id: params[:supplier_id]})
      end

      payments.each do |p|
        total_PAD_buy_paid += p.amount
      end

      order_ids = payments.map(&:order_id)
      buy_orders = buy_orders.where(id: order_ids)
    else
      buy_orders = buy_orders.where('order_date >= ?', from_date)
                                .where('order_date <= ?', to_date)
    end

    if params[:supplier_id].present?
      buy_orders = buy_orders.where(supplier_id: params[:supplier_id])
    end
    if params[:paid_status].present? && params[:paid_status] == "paid"
      buy_orders = buy_orders.where(payment_status_name: "paid")
    end
    if params[:paid_status].present? && params[:paid_status] == "not_paid"
      buy_orders = buy_orders.where("payment_status_name != 'paid'")
    end

    buy_orders.each do |order|
      if order.parent.nil?
        total_buy += order.total
        total_buy_with_vat += order.total_vat
        total_vat_buy += order.vat_amount

        payment_paid_vat += order.paid_amount
        payment_paid += order.paid_amount - order.vat_amount
        payment_vat_paid += order.vat_amount

        total_buy_with_vat_notpaid += order.remain_amount
        total_buy_with_vat_paid += order.paid_amount
      end
    end

    buy_orders = buy_orders.sort {|a,b| a[:printed_order_number].to_i <=> b[:printed_order_number].to_i}
    sell_orders = sell_orders.sort {|a,b| a[:printed_order_number].to_i <=> b[:printed_order_number].to_i}


    return {
      total_buy: total_buy,
      total_sell: total_sell,
      total_buy_with_vat: total_buy_with_vat,
      total_sell_with_vat: total_sell_with_vat,
      total_vat_buy: total_vat_buy,
      total_vat_sell: total_vat_sell,

      payment_paid_vat: payment_paid_vat,
      payment_paid: payment_paid,
      payment_vat_paid: payment_vat_paid,
      payment_recieved_vat: payment_recieved_vat,
      payment_recieved: payment_recieved,
      payment_vat_recieved: payment_recieved_vat - payment_recieved,

      total_buy_with_vat_notpaid: total_buy_with_vat_notpaid,
      total_sell_with_vat_notpaid: total_sell_with_vat_notpaid,
      total_buy_with_vat_paid: total_buy_with_vat_paid,
      total_sell_with_vat_paid: total_sell_with_vat_paid,

      total_tip_amount_notpaid: total_tip_amount_notpaid,
      total_tip_amount_paid: total_tip_amount_paid,

      sell_orders: sell_orders,
      buy_orders: buy_orders,

      total_PAD_sell_paid: total_PAD_sell_paid,
      total_PAD_buy_paid: total_PAD_buy_paid,

      total_fare: total_fare,
      total_fare_vat: total_fare - total_fare*(0.25),
      total_cost: total_cost
    }
  end

  def self.statistics_custom(from_date, to_date, params = {}, min_order_detail_price)
    total_buy = 0.00
    total_sell = 0.00
    total_buy_with_vat = 0.00
    total_sell_with_vat = 0.00
    total_vat_buy = 0.00
    total_vat_sell = 0.00

    total_buy_with_vat_notpaid = 0.00
    total_sell_with_vat_notpaid = 0.00
    total_buy_with_vat_paid = 0.00
    total_sell_with_vat_paid = 0.00

    total_tip_amount_notpaid = 0.00
    total_tip_amount_paid = 0.00

    total_PAD_buy_paid = 0.00
    total_PAD_sell_paid = 0.00

    total_fare = 0.00
    total_cost = 0.00

    sell_orders = Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: "finished"})

    sell_orders = sell_orders.where('order_date >= ?', from_date.beginning_of_day)
                                .where('order_date <= ?', to_date.end_of_day)


    if params[:customer_id].present?
      sell_orders = sell_orders.where(customer_id: params[:customer_id])
    end
    if params[:tip_contact_id].present?
      sell_orders = sell_orders.where(tip_contact_id: params[:tip_contact_id])
    end
    if params[:paid_status].present? && params[:paid_status] == "paid"
      sell_orders = sell_orders.where(payment_status_name: "paid")
    end
    if params[:paid_status].present? && params[:paid_status] == "not_paid"
      sell_orders = sell_orders.where("payment_status_name != 'paid'")
    end
    if params[:paid_status].present? && params[:paid_status] == "out_of_date"
      sell_orders = sell_orders.where(payment_status_name: 'out_of_date')
    end


    sell_orders.each do |order|
      if order.parent.nil?
		order.order_details.where("price >= " + min_order_detail_price.to_s).each do |od|
			total_sell += od.total
			total_sell_with_vat += od.total_vat
			total_vat_sell += od.vat_amount

			total_tip_amount_notpaid += order.tip_amount if !order.is_tipped
			total_tip_amount_paid += order.tip_amount if order.is_tipped

			total_fare += od.fare
			total_cost += od.cost
		end
      end
    end

    buy_orders = Order.purchase_orders
                  .joins(:order_status).where(order_statuses: {name: "finished"})

    buy_orders = buy_orders.where('order_date >= ?', from_date)
                                .where('order_date <= ?', to_date)

    if params[:supplier_id].present?
      buy_orders = buy_orders.where(supplier_id: params[:supplier_id])
    end
    if params[:paid_status].present? && params[:paid_status] == "paid"
      buy_orders = buy_orders.where(payment_status_name: "paid")
    end
    if params[:paid_status].present? && params[:paid_status] == "not_paid"
      buy_orders = buy_orders.where("payment_status_name != 'paid'")
    end

    buy_orders.each do |order|
      if order.parent.nil?
		order.order_details.where("price >= " + min_order_detail_price.to_s).each do |od|
			total_buy += od.total
			total_buy_with_vat += od.total_vat
			total_vat_buy += od.vat_amount
		end
      end
    end

    buy_orders = buy_orders.sort {|a,b| a[:printed_order_number].to_i <=> b[:printed_order_number].to_i}
    sell_orders = sell_orders.sort {|a,b| a[:printed_order_number].to_i <=> b[:printed_order_number].to_i}


    return {
      total_buy: total_buy,
      total_sell: total_sell,
      total_buy_with_vat: total_buy_with_vat,
      total_sell_with_vat: total_sell_with_vat,
      total_vat_buy: total_vat_buy,
      total_vat_sell: total_vat_sell,

      total_tip_amount_notpaid: total_tip_amount_notpaid,
      total_tip_amount_paid: total_tip_amount_paid,

      sell_orders: sell_orders,
      buy_orders: buy_orders,

      total_fare: total_fare,
      total_fare_vat: total_fare - total_fare*(0.25),
      total_cost: total_cost
    }
  end

  def self.delivery_sales_orders
    Order.customer_orders
                  .where(order_status_name: ["canceled","confirmed","finished"]) # orders confirmed
  end

  def self.delivery_purchase_orders
    Order.purchase_orders
                  .where(order_status_name: ["canceled","confirmed","finished"]) # orders confirmed
  end

  def self.accounting_sales_orders
    Order.customer_orders
                  .where(order_status_name: ["canceled","confirmed","finished"]) # orders confirmed
  end

  def self.accounting_purchase_orders
    Order.purchase_orders
                  .where(order_status_name: ["canceled","confirmed","finished"]) # orders confirmed
  end

  pg_search_scope :search,
                against: [:shipping_place, :tip_status_name,:customer_po, :printed_order_number, :order_status_name, :delivery_status_name, :quotation_code, :buyer_company, :buyer_name, :buyer_tax_code, :buyer_address, :buyer_email],
                associated_against: {
                  salesperson: [:first_name],
                  purchaser: [:first_name],
                  supplier: [:name, :tax_code, :address, :email],
                  order_details: [:product_name, :product_description],
                  #order_status: [:name]
                },
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.get_query(params, user)
    if !params["order"].nil? && !params["order"]["0"].nil?
      case params[:page]
      when "accounting"
        case params["order"]["0"]["column"]
        when "0"
          order_by = "orders.printed_order_number"
        end

      else
        case params["order"]["0"]["column"]
        when "0"
          order_by = "orders.printed_order_number"
        when "4"
          order_by = "orders.debt_date"
        else
          order_by = "orders.created_at"
        end

      end


      order_by += " "+params["order"]["0"]["dir"]
    else
        order_by = "orders.created_at DESC"
    end

    if params[:order_by].present?
      order_by = "orders."+params[:order_by]+" "+params[:order_by_cend]
    end


    where = {}
    where[:customer_id] = params["customer_id"] if params["customer_id"].present?
    where[:supplier_id] = params["supplier_id"] if params["supplier_id"].present?


    if params[:page].present? && params[:page] == "accounting"
      if params[:purchase]
        @items = self.accounting_purchase_orders
      else
        @items = self.accounting_sales_orders
      end

      if params["payment_status"].present? && params["payment_status"] == "waiting" && params["search"]["value"].empty?
        @items = @items.where(
                  "payment_status_name IN ('not_deposited', 'pay_back', 'out_of_date')"
                )
      end
    elsif params[:page].present? && params[:page] == "delivery"
      if params[:purchase]
        @items = self.delivery_purchase_orders
      else
        @items = self.delivery_sales_orders
      end

      if params["delivery_status"].present? && params["delivery_status"] == "waiting" && params["search"]["value"].empty?
        @items = @items.where("delivery_status_name LIKE ? OR delivery_status_name LIKE ?", "%not_delivered%", "%return_back%")
      end
    else
      if params[:purchase]
        @items = self.purchase_orders
        if !user.can?(:view_all_sales_orders, Order)
          @items = @items.where("purchaser_id=?",user.id)
        end
      else
        @items = self.customer_orders
        if !user.can?(:view_all_sales_orders, Order)
          @items = @items.where("salesperson_id=?",user.id)
        end
      end

      if params["order_status"].present? && params["order_status"] == "waiting" && params["search"]["value"].empty?
        @items = @items.where(order_status_name: [nil, "new", "items_confirmed", "price_confirmed"])
      end
    end

    @items = @items.joins(:order_status)
    #@items = @items.where(order_statuses: {name: params["order_status"]}) if params["order_status"].present? && params["order_status"] != "waiting" && params["search"]["value"].empty?
    @items = @items.where(order_status_name: params["order_status"]) if params["order_status"].present? && params["order_status"] != "waiting" && params["search"]["value"].empty?
    @items = @items.where("delivery_status_name LIKE ?", "%#{params["delivery_status"]}%") if params["delivery_status"].present?  && params["delivery_status"] != "waiting" && params["search"]["value"].empty?
    @items = @items.where("payment_status_name LIKE ?", "%#{params["payment_status"]}%") if params["payment_status"].present?  && params["payment_status"] != "waiting" && params["search"]["value"].empty?
    @items = @items.where("tip_status_name = ?", "#{params["tip_status"]}") if params["tip_status"].present?
    @items = @items.where('extract(year from order_date AT TIME ZONE ?) = ?', Time.zone.tzinfo.identifier, params["year"]) if params["year"].present?
    @items = @items.where('extract(month from order_date AT TIME ZONE ?) = ?', Time.zone.tzinfo.identifier, params["month"]) if params["month"].present?
    @items = @items.where('extract(day from order_date AT TIME ZONE ?) = ?', Time.zone.tzinfo.identifier, params["day"]) if params["day"].present?

    @items = @items.where(where)

    # SEARCHING @items = @items.search(params["search"]["value"]) if !params["search"]["value"].empty?
    if params["search"].present? and params["search"]["value"].present?
      params["search"]["value"].split(" ").each do |k|
        @items = @items.where("LOWER(orders.cache_search) LIKE ?", "%#{k.strip.downcase}%") if k.strip.present?
      end
    end

    @items = @items.order(order_by) if !order_by.nil?
    
    return @items
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers

    app_helper = ApplicationController.helpers

    @items = self.get_query(params, user)
    
    # save params
    if params[:report_hook].present?
      File.open('report/report_' + params[:report_hook] + '.yml', 'w') { |f| f.write(YAML.dump(params)) }
    end
    
    ######

    total = @items.count(:all)

    @items = @items.limit(params[:length]).offset(params["start"])
    data = []

    actions_col = 7
    @items.each do |item|

      if params[:purchase]
        name_col = item.supplier.short_name
      else
        name_col = item.customer.short_name
      end

      if !item.is_purchase
        staff_col = item.salesperson.staff_col
      else
        staff_col = item.purchaser.staff_col
      end


      puts User.current_user

      printed_order_number = item.printed_order_number.present? ? "<br /><strong class=\"finished\">#{item.printed_order_number}</strong>" : ""

      first_col = link_helper.link_to(item.quotation_code, {controller: "orders", action: "show", id: item.id, tab_page: 1}, class: "tab_page", title: "Order [#{item.quotation_code}]")
      first_col += ("<br />"+item.customer_po).html_safe if item.customer_po.present?
      first_col += printed_order_number.html_safe if item.printed_order_number.present?

      case params[:page]
      when "delivery"
          row = [
                  first_col,
                  link_helper.link_to(name_col, {controller: "orders", action: "show", id: item.id, tab_page: 1}, class: "tab_page main-title", title: "Order [#{item.quotation_code}]")+item.display_description,
                  "<div class=\"text-center\">#{staff_col}</div>",
                  '<div class="text-center">'+item.order_date_formatted+'</div>',
                  '<div class="text-center">'+item.display_order_status_name+'</div>',
                  "<div class=\"text-center\">#{item.display_payment_status_name}</div>",
                  "<div class=\"text-center\">#{item.display_delivery_status_name}<strong>#{item.items_delivered}</strong>/#{item.items_total}</div>",
                  app_helper.render_order_actions(item)
                ]
          data << row
          actions_col = 7
      when "accounting"
        debt_time = item.is_debt || item.is_out_of_date ? item.debt_remain_days.to_s+'<br />days' : ""
          row = [
                  '<div class="nowrap">'+first_col+'</div>',
                  link_helper.link_to(name_col, {controller: "orders", action: "show", id: item.id, tab_page: 1}, class: "tab_page main-title", title: "Order [#{item.quotation_code}]")+item.display_description,
                  "<div class=\"text-center\">#{staff_col}</div>",
                  '<div class="text-center">'+item.order_date_formatted+'</div>',
                  '<div class="text-center">'+debt_time+'</div>',
                  '<div class="text-center">'+item.display_order_status_name+item.display_delivery_status_name+'</div>',
                  "<div class=\"text-center\">#{item.display_payment_status_name}Paid:<strong>#{item.paid_amount_formated}</strong><br />Total:#{item.formated_total_vat}<br />Remain:#{item.remain_amount_formated}#{item.display_tip_status_name}</div>#{item.display_last_payment}",
                  app_helper.render_order_actions(item)
                ]
          data << row
          actions_col = 7
      else

          row = [
                  first_col,
                  link_helper.link_to(name_col, {controller: "orders", action: "show", id: item.id, tab_page: 1}, class: "tab_page main-title", title: "Order [#{item.quotation_code}]")+item.display_description,
                  '<div class="text-right">'+item.formated_total_vat+'</div>',
                  "<div class=\"text-center\">#{staff_col}</div>",
                  '<div class="text-center">'+item.order_date_formatted+'</div>',
                  "<div class=\"text-center\">#{item.display_price_status_name}#{item.display_delivery_status_name}#{item.display_payment_status_name}</div>",
                  '<div class="text-center">'+item.display_order_status_name+'</div>',
                  app_helper.render_order_actions(item)
                ]
          data << row
          actions_col = 7
      end

    end


    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data

    return {result: result, items: @items, actions_col: actions_col}
  end

  def items_total
    order_details.sum :quantity
  end

  def items_delivered
    total = 0
    order_details.each do |line|
      total += line.delivered_count
    end

    return total
  end

  def items_delivery_remain
    items_total - items_delivered
  end

  def is_combinable
    order_details.each do |od|
      if od.is_combinable
        return true
      end
    end
    return false
  end

  def delivery_status
    status_arr = []
    if ["confirmed","finished"].include?(status.name)
      if is_delivered?
        status_arr << 'delivered'
      else
        if has_delvery_items
          status_arr << 'not_delivered'
        end
        if is_out_of_stock
          status_arr << 'out_of_stock'
        end
        if is_combinable
          status_arr << 'combinable'
        end
      end
    end

    if has_return_items
      status_arr << 'return_back'
    end

    #self.update_attributes(delivery_status_name: status_arr.join(",")) # if status_arr.join(",") != delivery_status_name

    return status_arr
  end

  def display_delivery_status
    str = ""
    delivery_status.each do |s|
      str += "<div class=\"#{s}\">#{s}</div>"
    end
    return str.html_safe
  end

  def display_delivery_status_name
    str = ""
    delivery_status_name.split(",").each do |s|
      str += "<div class=\"#{s}\">#{s}</div>"
    end
    return str.html_safe
  end

  def paid_amount
    all_order_payments.sum :amount
  end

  def tipped_amount
    all_tip_payments.sum :amount
  end

  def commissioned_amount
    all_commission_payments.sum :amount
  end

  def commission_remain
    commission[:amount] - commissioned_amount
  end

  def is_tipped
    tip_amount == tipped_amount
  end

  def is_commissioned
    commission[:amount] == commissioned_amount
  end

  def remain_amount
    if ["confirmed","finished"].include?(self.status.name)
      total_vat - paid_amount
    elsif ["canceled"].include?(self.status.name)
      paid_amount
    else
      0
    end
  end

  def remain_tip
    tip_amount - tipped_amount
  end

  def remain_amount_formated
    Order.format_price(remain_amount)
  end

  def paid_amount_formated
    Order.format_price(paid_amount)
  end

  def is_paid
    if ["confirmed","finished"].include?(self.status.name)
      total_vat == paid_amount
    elsif ["canceled"].include?(self.status.name)
      return false
    end

  end

  def is_payback
    if ["confirmed","finished"].include?(self.status.name)
      paid_amount > total_vat
    elsif ["canceled"].include?(self.status.name)
      paid_amount > 0
    else
      return false
    end
  end


  def payment_status
    status = ""

    if ["confirmed","finished"].include?(self.status.name)
      if paid_amount == total_vat
        status = "paid"
      elsif !is_deposited
        status = "not_deposited"
      elsif is_debt
        status = "debt"
      elsif is_out_of_date
        status = "out_of_date"
      else
        status = "out_of_date"
      end
    end

    if is_payback
        status = "pay_back"
    end

    #update_attributes(payment_status_name: status)

    return status
  end

  def is_debt
    if ["confirmed","finished"].include?(status.name)
      is_deposited && !debt_date.nil? && debt_date >= Time.now.beginning_of_day && paid_amount != total_vat
    else
      return false
    end
  end
  def is_out_of_date
    is_deposited && !debt_date.nil? && debt_date < Time.now.beginning_of_day && paid_amount != total_vat
  end

  def display_payment_status
    return "<div class=\"#{payment_status}\">#{payment_status}</div>".html_safe
  end


  def save_as_new(order_params)
      new_params = order_params.dup
      new_params[:order_detail_ids] = []
      @dup_order = Order.new(new_params)

      @dup_order.create_quotation_code


      @dup_order.supplier = self.supplier
      @dup_order.customer = self.customer

      @dup_order.save

      @dup_order.drafts << self
      self.save

      self.drafts.each do |o|
        @dup_order.drafts << o
        o.save
      end

      if !order_params[:order_detail_ids].nil?
        order_params[:order_detail_ids].each do |id|
          if self.order_details.map(&:id).include?(id.to_i)
            od = self.order_details.find_by_id(id.to_i).dup
            od.save
            @dup_order.order_details << od
          else
            @dup_order.order_details << OrderDetail.find_by_id(id.to_i)
          end
        end
      end

      return @dup_order
  end

  def is_delivered?
    # return items_delivered == items_total

    if ["confirmed","finished"].include?(status.name)
      order_details.each do |line|
        if line.delivered_count != line.quantity
          return false
        end
      end

      return true
    else
      return false
    end
  end

  def has_return_items
    if ["confirmed","finished"].include?(status.name)
      order_details.each do |line|
        if line.delivered_count > line.quantity
          return true
        end
      end
    elsif ["canceled"].include?(status.name)
      order_details.each do |line|
        if line.delivered_count > 0
          return true
        end
      end
    end

    return false
  end

  def has_deliver_items
    if ["confirmed","finished"].include?(status.name)
      order_details.each do |line|
        if line.delivered_count < line.quantity
          return true
        end
      end
    elsif ["canceled"].include?(status.name)
      return false
    end

    return false
  end

  def has_delvery_items
    order_details.each do |line|
      if line.delivered_count < line.quantity
        return true
      end
    end

    return false
  end

  def is_out_of_stock
    order_details.each do |line|
      if line.is_out_of_stock
        return true
      end
    end

    return false
  end

  def display_status
    if self.status.nil?
    else
      "<div class=\"#{status.name}\">#{status.name}</div>".html_safe
    end
  end

  def display_order_status_name
    if self.status.nil?
    else
      "<div class=\"#{order_status_name}\">#{order_status_name}</div>".html_safe
    end
  end

  def display_payment_status_name
    if self.status.nil?
    else
      "<div class=\"#{payment_status_name}\">#{payment_status_name}</div>".html_safe
    end
  end
  
  def display_last_payment
    last_payment = self.all_order_payments.last
    paid_info = (!last_payment.nil? ? "Last.payment: #{ApplicationController.helpers.format_price(last_payment.amount, false, true)}|#{last_payment.paid_date.strftime("%Y-%m-%d")}|#{last_payment.bank_account_name}" : '')
    
    "<br><div>#{paid_info}</div>".html_safe
  end

  def out_of_stock_details
    str = ""

    if is_out_of_stock
      order_details.each do |od|
        str += '<div>'+od.product_name+'(<strong class="red">-'+od.out_of_stock_count.to_s+'</strong>) '+'</div>' if od.is_out_of_stock
      end
    end

    return str.html_safe
  end

  def out_of_stock_order_details
    arr = []

    if is_out_of_stock
      order_details.each do |od|
        arr << od if od.is_out_of_stock
      end
    end

    return arr
  end

  def self.pricing_orders(user)
    orders = Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})

    orders_2 = Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: ["confirmed","finished"]})
                  .where("delivery_status_name LIKE ?", '%out_of_stock%')

    orders_total = orders + orders_2
    orders_total.sort{|a,b| b[:created_at] <=> a[:created_at]}
  end

  def confirm_price(user)
    order_details.each do |od|
      if (od.product.product_prices.count == 0) && od.quantity > 0
        return false
      end
    end

    set_status("price_confirmed",user)
    Notification.send_notification(purchaser, 'order_price_confirmed', self)

    return true
  end

  def purchaser_name
    purchaser.nil? ? "" : purchaser.name
  end

  def salesperson_name
    salesperson.nil? ? "" : salesperson.name
  end

  def debt_days
    if !debt_date.nil?
      (debt_date.to_date - order_date.to_date).to_i
    else
      Time.now
    end
  end

  def debt_remain_days
    if !debt_date.nil?
      (debt_date.to_date - Time.now.to_date).to_i
    else
      Time.now
    end
  end

  def debt_date_formated
    if !debt_date.nil?
      debt_date.to_date
    else
      Time.now.to_date
    end
  end

  def paid_percent
    ((paid_amount/total_vat)*100).round(2)
  end

  def payment_out_of_date
    is_deposited && !debt_date.nil? && debt_date < order_date
  end

  def is_deposited
    d = !deposit.nil? ? deposit : 100
    paid_percent >= d
  end

  def update_order_details(order_details_params)

    if order_details_params.nil?
      return false
    end

    # Update current order details
    self.order_details.each do |od|
      order_details_params.each do |line|
        if line[:product_id].to_i == od.product_id
          od.update_attributes(
            product_name: line[:product_name],
            product_description: line[:product_description],
            unit: line[:unit],
            price: line[:price],
            quantity: line[:quantity],
            warranty: line[:warranty],
            discount_amount: line[:discount_amount],
            tip_amount: line[:tip_amount],
            shipment_amount: line[:shipment_amount],
            tax_id: line[:tax_id]
          )
        end
      end
    end

    # Insert new order details
    od_pids = []
    self.order_details.each do |od|
      od_pids << od.product_id
    end
    order_details_params.each do |line|
      if !od_pids.include?(line[:product_id].to_i)
        self.order_details.create(line)
      end
    end
  end

  def update_order_details_info(order_details_params)

    if order_details_params.nil?
      return false
    end

    # Update current order details
    self.order_details.each do |od|
      order_details_params.each do |line|
        if line[:product_id].to_i == od.product_id

          od.update_attributes(
            product_name: line[:product_name],
            product_description: line[:product_description],
            unit: line[:unit],
            discount_amount: line[:discount_amount],
            tip_amount: line[:tip_amount]
          )
        end
      end
    end
  end

  def update_order_detail_tips(order_details_params)

    if order_details_params.nil?
      return false
    end

    # Update current order details
    self.order_details.each do |od|
      order_details_params.each do |line|
        if line[:product_id].to_i == od.product_id

          od.update_attributes(
            tip_amount: line[:tip_amount]
          )
        end
      end
    end
  end

  def all_deliveries
    deliveries.where(status: 1).order("created_at DESC")
  end

  def save_draft(user)
    draft = self.dup
    draft.parent_id = self.id
    draft.user = user

    draft.save
    self.order_details.each do |od|
      draft_od = od.dup
      draft_od.order_id = draft.id
      draft_od.save
    end

    draft.parent = self
    #draft.set_status("draft",user)
  end

  def all_order_payments
    payment_records.where(type_name: 'order')
                  .where(status: 1)
                  .order("created_at DESC")
  end
  def all_tip_payments
    payment_records.where(type_name: 'tip')
                  .where(status: 1)
                  .order("created_at DESC")
  end
  def all_custom_payments
    payment_records.where(type_name: 'custom')
                  .where(status: 1)
                  .order("created_at DESC")
  end
  def all_commission_payments
    payment_records.where(type_name: 'commission')
                  .where(status: 1)
                  .order("created_at DESC")
  end

  def is_prices_oudated
    order_details.each do |od|
      if od.is_price_outdated && od.quantity > 0
        return true
      end
    end

    return false
  end

  def price_status
    status = ""
    if is_prices_oudated
      status = "price_outdated"
    else
      status = "price_updated"
    end

    #update_attributes(price_status_name: status)

    return status
  end

  def display_price_status
    return "<div class=\"#{price_status}\">#{price_status}</div>".html_safe
  end

  def display_price_status_name
    return "<div class=\"#{price_status_name}\">#{price_status_name}</div>".html_safe
  end

  def is_price_updated
    if price_status == "price_updated"
        return true
    else
      return false
    end
  end

  def display_title
    if ['confirmed'].include?(status.name)
      return "ĐƠN HÀNG"
    elsif ['finished'].include?(status.name)
      return "HÓA ĐƠN"
    elsif ['canceled'].include?(status.name)
      return "ĐÃ HỦY"
    else
      return "BẢNG BÁO GIÁ"
    end

  end

  def display_title_en
    if ['confirmed'].include?(status.name)
      return "ORDER"
    elsif ['finished'].include?(status.name)
      return "ORDER"
    elsif ['canceled'].include?(status.name)
      return "CANCELED"
    else
      return "QUOTATION"
    end

  end

  def display_description
    arr = []
    order_details.each do |od|
      p_str = "<div class=\"order-desc-line-item quantity-#{od.quantity}\">"
      p_str += "<label>#{od.quantity.to_s}</label> "
      p_str += od.product.display_name.strip
      p_str += "</div>"
      arr << p_str
    end

    str = "<div class=\"order-desc-line-items\">"+arr.join(" ")+"</div>"
    return str.html_safe
  end

  def discount_amount=(new_price)
    self[:discount_amount] = new_price.to_s.gsub(/\,/, '')
  end
  def tip_amount=(new_price)
    self[:tip_amount] = new_price.to_s.gsub(/\,/, '')
  end

  def order_link(text=nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers

    text = text.nil? ? "<i class=\"icon-file-text-alt\"></i> ".html_safe+self.quotation_code : text

    link = link_helper.link_to(text, {controller: "orders", action: "show", id: self.id, tab_page: 1}, title: "Order [#{quotation_code}]", class: "tab_page")

    return link.html_safe
  end

  def order_log
    history = []
    #created at
    if self.is_purchase
      line = {user: self.purchaser, date: self.created_at, note: "Ordered to [#{self.supplier.name}]", link: self.order_link, quantity: ""}
    else
      line = {user: self.salesperson, date: self.created_at, note: "Ordered from [#{self.customer.name}]", link: self.order_link, quantity: ""}
    end
    history << line

    #status
    order_statuses.each do |os|
      oso = OrderStatusesOrder.where(order_id: self.id, order_status_id: os.id).first
      line = {user: oso.user, date: oso.created_at, note: "Status changed to [<span class=\"#{os.name}\">#{os.name}</span>]", link: self.order_link, quantity: ""}
      history << line
    end

    #status
    all_deliveries.each do |d|
      o = d.order
      if o.is_purchase
        if d.is_return == 1
          line = {user: d.creator, date: d.delivery_date, note: "Return items to [#{o.supplier.name}]", link: d.delivery_link, quantity: d.delivery_details.sum(:quantity)}
        else
          line = {user: d.creator, date: d.delivery_date, note: "Recieved items from [#{o.supplier.name}]", link: d.delivery_link, quantity: d.delivery_details.sum(:quantity)}
        end
      else
        if d.is_return == 1
          line = {user: d.creator, date: d.delivery_date, note: "Recieved returned items to [#{o.customer.name}]", link: d.delivery_link, quantity: d.delivery_details.sum(:quantity)}
        else
          line = {user: d.creator, date: d.delivery_date, note: "Deliver items to [#{o.customer.name}]", link: d.delivery_link, quantity: d.delivery_details.sum(:quantity)}
        end
      end

      history << line
    end

    #payment
    all_order_payments.each do |p|
      o = p.order
      if o.is_purchase
        if p.amount < 0
          line = {user: p.accountant, date: p.paid_date, note: "Recieved from [#{o.supplier.name}]", link: p.payment_record_link, quantity: p.amount_formated}
        else
          line = {user: p.accountant, date: p.paid_date, note: "Paid [#{o.supplier.name}]", link: p.payment_record_link, quantity: p.amount_formated}
        end
      else
        if p.amount > 0
          line = {user: p.accountant, date: p.paid_date, note: "Recieved from [#{o.customer.name}]", link: p.payment_record_link, quantity: p.amount_formated}
        else
          line = {user: p.accountant, date: p.paid_date, note: "Paid [#{o.customer.name}]", link: p.payment_record_link, quantity: p.amount_formated}
        end
      end
      history << line
    end

    #draft
    drafts.each do |d|
      line = {user: d.user, date: d.created_at, note: "Updated/Changed", link: d.order_link, quantity: ""}
      history << line
    end

    return history.sort {|a,b| b[:date] <=> a[:date]}
  end

  def tip_status
    status = ""

    if ["finished"].include?(self.status.name) && tip_amount > 0
      if is_tipped
        status = "tipped"
      else
        status = "not_tipped"
      end
    end

    #update_attributes(tip_status_name: status)

    return status
  end

  def display_tip_status
    return "<div class=\"#{tip_status}\">#{tip_status}</div>".html_safe
  end

  def display_tip_status_name
    return "<div class=\"#{tip_status_name}\">#{tip_status_name}</div>".html_safe
  end

  def tip_amount
    order_details.where("quantity > 0").sum(:tip_amount)
  end

  def discount_amount
    order_details.where("quantity > 0").sum(:discount_amount)
  end

  def update_order_status_name
    update_attribute(:order_status_name, self.order_status.name) if self.order_status.present? && self.order_status.name != self.order_status_name
  end

  def update_payment_status_name
    update_attribute(:payment_status_name, payment_status) if payment_status_name != payment_status
  end

  def update_delivery_status_name
    update_attributes(delivery_status_name: delivery_status.join(",")) if delivery_status.join(",") != delivery_status_name
  end

  def update_price_status_name
    update_attributes(price_status_name: price_status) if price_status_name != price_status
  end

  def update_tip_status_name
    update_attributes(tip_status_name: tip_status) if tip_status_name != tip_status
  end

  def update_status_names
    #order status
    self.update_order_status_name
    #payment
    self.update_payment_status_name
    #delivery
    self.update_delivery_status_name
    #price_status
    self.update_price_status_name
    #tip status
    self.update_tip_status_name
  end

  def check_debt_outdate
    if self.debt_date < Time.now.beginning_of_day
      self.update_attribute(:payment_status_name, "out_of_date")
      return true
    else
      return false
    end
  end

  def payments_by_date(d)
    all_order_payments.where('paid_date >= ?', d.beginning_of_day)
                        .where('paid_date <= ?', d.end_of_day)
  end

  def fare
    result = 0.00

    order_details.each do |od|
      result += od.fare
    end

    return result
  end

  def fare_vat
    if fare > 0
      fare - fare*(0.25)
    else
      fare - fare.abs*0.1
    end
  end

  def cost
    result = 0.00

    order_details.each do |od|
      result += od.cost_total
    end

    return result
  end

  def last_payment_record
    payment_records.order("paid_date DESC").first
  end

  def commission
    commission = {amount: 0.00, program: nil}

    # month program
    #current_month = Time.now.beginning_of_month
    #if order_date <= current_month
      # get total month sales
      month_state = CommissionProgram.sales_statistics(salesperson, order_date.beginning_of_month, order_date.end_of_month)
      if !month_state.nil?
        month_program = choose_commission_program(month_state[:total_sell], "month")

        program = month_program if !month_program.nil? && (program.nil? || month_program.commission_rate > program.commission_rate)
      end
    #end

    # year program
    #current_year = Time.now.beginning_of_year
    #if order_date <= current_year
      # get total month sales
      year_state = CommissionProgram.sales_statistics(salesperson, order_date.beginning_of_year, order_date.end_of_year)
      if !year_state.nil?
        year_program = choose_commission_program(year_state[:total_sell], "year")

        program = year_program if !year_program.nil? && (program.nil? || year_program.commission_rate > program.commission_rate)
      end
    #end

    if !program.nil?
      commission[:amount] = (program.commission_rate/100.00)*self.total
      commission[:program] = program
    end

    return commission
  end

  def commission_programs(interval_type)
    programs = CommissionProgram.where(status: 1).where(interval_type: interval_type).all_commission_programs.where("published_at <= ? AND unpublished_at >= ?", order_date.beginning_of_day, order_date.end_of_day)
  end

  def choose_commission_program(amount, interval_type)
    return commission_programs(interval_type).where("min_amount <= ? AND max_amount >= ?", amount, amount)
                                              .order("commission_rate DESC").first
  end

  def update_cache_total
    self.update_attribute(:cache_total, self.total)
  end

  def next_order
    if self.parent.nil?
      return nil
    end

    orders = self.parent.drafts.order(:created_at)

    orders.each do |o|
      if o.created_at > self.created_at
        return o
      end
    end

    return self.parent
  end

  def first_order
    if self.parent.nil?
      p = self
    else
      p = self.parent
    end

    return p.drafts.order("created_at DESC").empty? ? self : p.drafts.order("created_at").first
  end

  def update_cache_search
    str = []
    str << shipping_place.to_s.downcase.strip if shipping_place.present?
    str << tip_status_name.to_s.downcase.strip if tip_status_name.present?
    str << customer_po.to_s.downcase.strip if customer_po.present?
    str << printed_order_number.to_s.downcase.strip if printed_order_number.present?
    str << order_status_name.to_s.downcase.strip if order_status_name.present?
    str << delivery_status_name.to_s.downcase.strip if delivery_status_name.present?
    str << buyer_company.to_s.downcase.strip if buyer_company.present?
    str << buyer_name.to_s.downcase.strip if buyer_name.present?
    str << buyer_tax_code.to_s.downcase.strip if buyer_tax_code.present?
    str << buyer_address.to_s.downcase.strip if buyer_address.present?
    str << buyer_email.to_s.downcase.strip if buyer_email.present?

    str << salesperson.first_name.to_s.downcase.strip if salesperson.present?
    str << salesperson.last_name.to_s.downcase.strip if salesperson.present?
    str << purchaser.first_name.to_s.downcase.strip if purchaser.present?
    str << purchaser.last_name.to_s.downcase.strip if purchaser.present?

    str << supplier.name.to_s.downcase.strip if purchaser.present?
    str << supplier.tax_code.to_s.downcase.strip if purchaser.present?
    str << supplier.address.to_s.downcase.strip if purchaser.present?
    str << supplier.email.to_s.downcase.strip if purchaser.present?

    str << quotation_code.to_s.downcase.strip if quotation_code.present?

    order_details.each do |od|
      str << od.product_name.to_s.downcase.strip
      str << od.product_description.to_s.downcase.strip
    end

    self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").unaccent)
  end

  def self.sales_by_category(from_date=nil, to_date=nil, params = {})
    # times
    from_date = from_date.present? ? from_date.to_date : DateTime.now.beginning_of_month
    to_date =  to_date.present? ? to_date.to_date.end_of_day : DateTime.now

    result = {
      from_date: from_date,
      to_date: to_date,
      total: 0,
      quantity: 0,
      records: []
    }

    # get categories
    categories = Category.all

    # wrong: Order.customer_orders.joins(:order_details).where(order_details: {product_id: Category.find(2).products.map(&:id)}).sum(:cache_total).to_f
    # .to_a.sum(&:total).to_f
    # OrderDetail.includes(:order => :order_statuses).where(order_statuses: {name: "finished"}).where("orders.supplier_id="+Contact.HK.id.to_s).where(orders: {parent_id: nil}).where(product_id: Category.find(2).products.map(&:id)).to_a.sum(&:total).to_f

    categories.each_with_index do |c,index|
      order_details = OrderDetail.includes(:order => :order_statuses, :product => :categories)
        .where(order_statuses: {name: "finished"})
        .where("orders.supplier_id="+Contact.HK.id.to_s)
        .where(orders: {parent_id: nil})
        .where(product_id: Category.find(c.id.to_s).products.map(&:id))
        .where('orders.order_date >= ?', from_date.beginning_of_day)
        .where('orders.order_date <= ?', to_date.end_of_day)

      if params[:without_kddi].present?
        order_details = order_details.where.not(orders: {customer_id: [58,486,62,862]})
      end

      row = {
        category: c.name,
        total: order_details.to_a.sum(&:total).to_f,
        quantity: order_details.sum(:quantity)
      }
      if row[:total] > 0 and row[:quantity] > 0
        result[:total] += row[:total]
        result[:quantity] += row[:quantity]
        result[:records] << row
      end
    end

    result[:records] = result[:records].sort {|a,b| b[:total].to_i <=> a[:total].to_i}

    return result
  end
end
