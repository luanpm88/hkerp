class PaymentRecord < ActiveRecord::Base
  belongs_to :order
  belongs_to :accountant, :class_name => "User"
  belongs_to :payment_method
  belongs_to :user
  belongs_to :bank_account

  # ---------------------------------------------------------------------------
  # Cash (a.k.a. "custom") pay / receive records
  #
  # Direction is encoded in the SIGN of `amount`, and that is the single source
  # of truth — `is_paid` and every report (cash_book, account_book, statistics,
  # total_cash) derive the direction from it:
  #
  #     amount < 0  =>  Pay      (money leaves the company)
  #     amount > 0  =>  Receive  (money comes in)
  #
  # The `is_recieved` column exists but was historically never populated
  # correctly: the old form submitted it as a top-level `is_recieved` param
  # while strong params only permitted it nested under `payment_record[...]`,
  # so it silently kept its `false` default. On production 1,091 of the 1,096
  # receive records still carry `is_recieved = false`. It is now kept in sync
  # with the sign by `normalise_cash_direction` and is safe to read, but any
  # new logic should still prefer `cash_direction` / the sign.
  # ---------------------------------------------------------------------------
  CASH_TYPE       = 'custom'.freeze
  CASH_DIRECTIONS = %w(pay receive).freeze

  scope :cash_records,  -> { where(type_name: CASH_TYPE, status: 1) }
  scope :cash_pays,     -> { cash_records.where('amount < 0') }
  scope :cash_receives, -> { cash_records.where('amount >= 0') }

  # Set by the controller when creating a record so the sign can be applied
  # before validation. On an existing record the direction is immutable — the
  # persisted sign wins — which is what stops an edit from silently turning a
  # Pay into a Receive.
  attr_accessor :cash_direction_input

  before_validation :normalise_cash_direction, if: :cash_record?

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

  # --- Cash pay/receive helpers ----------------------------------------------

  def cash_record?
    type_name == CASH_TYPE
  end

  # 'pay' | 'receive' — derived from the amount sign, which is authoritative.
  # A brand-new unsaved record falls back to the direction the controller asked
  # for, so the form can render the right labels before anything is persisted.
  def cash_direction
    if amount.present?
      amount.to_f < 0 ? 'pay' : 'receive'
    else
      CASH_DIRECTIONS.include?(cash_direction_input) ? cash_direction_input : 'pay'
    end
  end

  def cash_pay?
    cash_direction == 'pay'
  end

  def cash_receive?
    cash_direction == 'receive'
  end

  def self.cash_direction_label(direction)
    direction.to_s == 'pay' ? 'Cash - Pay' : 'Cash - Receive'
  end

  def cash_direction_label
    self.class.cash_direction_label(cash_direction)
  end

  # Single place where a cash record's amount sign is decided.
  #
  # Runs on create AND update, which fixes two long-standing bugs:
  #   1. `is_recieved` was never persisted from the form, so the column was
  #      wrong for virtually every receive record.
  #   2. `update` re-saved whatever the user typed without re-applying the
  #      sign, so editing a Pay record and entering a positive amount silently
  #      converted it into a Receive (and vice versa).
  #
  # On a persisted record the direction cannot change: we re-apply the sign the
  # record already had. Direction is only taken from the controller for a new
  # record.
  def normalise_cash_direction
    return if amount.blank?

    direction =
      if new_record? && CASH_DIRECTIONS.include?(cash_direction_input)
        cash_direction_input
      elsif persisted?
        amount_was.to_f < 0 ? 'pay' : 'receive'
      else
        cash_direction
      end

    self.amount      = direction == 'pay' ? -amount.to_f.abs : amount.to_f.abs
    self.is_recieved = (direction == 'receive')

    # Rails 4.2 halts the callback chain when a before_* callback returns
    # false, and `valid?` then fails with an empty errors hash. Assigning
    # is_recieved = false on a Pay record would do exactly that, so return an
    # explicit truthy value. (Rails 5 replaced this with `throw :abort`.)
    true
  end
  private :normalise_cash_direction
  
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

  # Datatable feed for the split Cash - Pay / Cash - Receive screens.
  #
  # Unlike `datatable` (the old combined view, which needed a separate column
  # per direction and left one of them blank on every row) each screen shows a
  # single direction, so there is one unambiguous Amount column. Amounts are
  # rendered as absolute values — the direction is already stated by the page
  # the user is on, and showing "-1,500,000" under a heading that says "Pay"
  # was a large part of why the two got confused.
  #
  # Columns: 0 note | 1 amount | 2 paid_date | 3 actions
  def self.cash_datatable(params, direction)
    scope = direction.to_s == 'pay' ? cash_pays : cash_receives

    search = params[:search].is_a?(Hash) ? params[:search][:value].to_s.strip : ''
    if search.present?
      like = "%#{search}%"
      scope = scope.where('note ILIKE ? OR paid_person ILIKE ?', like, like)
    end

    scope = scope.reorder('paid_date DESC, created_at DESC')

    total   = scope.count
    records = scope.limit(params[:length]).offset(params['start'])

    data = records.map do |item|
      [
        item.note.to_s,
        '<div class="text-right">' + ApplicationController.helpers.format_price(item.amount.abs).to_s + '</div>',
        '<div class="text-center">' + (item.paid_date.present? ? item.paid_date.strftime('%Y-%m-%d') : '') + '</div>',
        '1'
      ]
    end

    {
      result: {
        'drawn'           => params[:drawn],
        'recordsTotal'    => total,
        'recordsFiltered' => total,
        'data'            => data
      },
      items:       records,
      actions_col: 3
    }
  end

  # Running total for the header of each cash screen.
  def self.cash_total(direction)
    scope = direction.to_s == 'pay' ? cash_pays : cash_receives
    scope.sum(:amount).to_f.abs
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
      if order.remain_tip.to_f != amount.to_f
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
    link_helper.link_to("<i class=\"icon-print\"></i>".html_safe+" Receipt ("+self.created_at.strftime("%Y-%m-%d")+")", {controller: "payment_records", action: "show", id: self.id, tab_page: 1}, :class => 'tab_page', title: "Receipt [#{created_at.strftime("%Y-%m-%d")}]").html_safe
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
  
  def bank_account_name
    bank_account.present? ? bank_account.name : ''
  end
  
end
