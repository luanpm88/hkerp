class PaymentRecordsController < ApplicationController
  include ApplicationHelper
  
  load_and_authorize_resource :except => [:pay_commission, :do_pay_commission, :pay_tip, :do_pay_tip]
  
  before_action :set_payment_record, only: [:edit_pay_custom, :edit_cash_record, :update_cash_record, :trash, :download_pdf, :show, :edit, :update, :destroy]

  # GET /payment_records
  # GET /payment_records.json
  def index
    @payment_records = PaymentRecord.all
  end
  
  # Legacy combined Custom Pay/Recieve screen.
  # Superseded by the split Cash - Pay / Cash - Receive screens; kept as a
  # redirect so old bookmarks and any stale tab state still land somewhere
  # sensible instead of 404ing.
  def custom_payments
    redirect_to cash_pays_payment_records_path(tab_page: params[:tab_page])
  end
  
  def datatable
    result = PaymentRecord.datatable(params)
    
    result[:items].each_with_index do |item, index|
      actions = render_custom_payments_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end

  # GET /payment_records/1
  # GET /payment_records/1.json
  def show
    if !@payment_record.order.nil?
      @order = @payment_record.order    
      @hk = @order.supplier
    else
      @hk = Contact.HK
    end
    
    
    
    render :layout => "content"
  end
  
  def download_pdf
    if !@payment_record.order.nil?
      @order = @payment_record.order    
      @hk = @order.supplier
    else
      @hk = Contact.HK
    end
    render  :pdf => "custom_payment_-"+@payment_record.id.to_s,
            :template => 'payment_records/show.pdf.erb',
            :layout => nil,
            :footer => {
               :center => "",
               :left => "",
               :right => "",
               :page_size => "A4",
               :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }
  end
  
  def download_pdf_2019
    if !@payment_record.order.nil?
      @order = @payment_record.order    
      @hk = @order.supplier
    else
      @hk = Contact.HK
    end
    render  :pdf => "custom_payment_-"+@payment_record.id.to_s,
            :template => 'payment_records/show_2019.pdf.erb',
            :layout => nil,
            :page_size => "A4",
            :footer => {
               :center => "",
               :left => "",
               :right => "",
               :page_size => "A5",
               :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }
  end

  # GET /payment_records/new
  def new
    @payment_record = PaymentRecord.new
    @payment_record.paid_date = (Time.now).strftime("%Y-%m-%d")
    
    if params[:order_id].present?
      @order = Order.find(params[:order_id])      
      @payment_record.paid_person = @order.is_purchase ? @order.supplier.name : @order.customer.name
      @payment_record.paid_address = @order.is_purchase ? @order.supplier.full_address : @order.customer.full_address
      @payment_record.amount = @order.remain_amount
      @payment_record.order_id = @order.id      
      
    end
    render layout: "content" if params[:tab_page].present?
  end
  
  def pay_tip
    @order = Order.find(params[:order_id])
    authorize! :pay_tip, @order
    
    @payment_record = PaymentRecord.new(is_tip: true)
    @payment_record.paid_date = (Time.now).strftime("%Y-%m-%d")
    
    render layout: "content" if params[:tab_page].present?
  end

  # GET /payment_records/1/edit
  def edit
  end

  # POST /payment_records
  # POST /payment_records.json
  def create
    @order = Order.find(payment_record_params[:order_id])
    @payment_record = @order.payment_records.new(payment_record_params)
    @payment_record.accountant = current_user
    @payment_record.type_name = 'order'
    
    
    if @order.is_payback
        @payment_record.amount = -@payment_record.amount.abs
    end
    
    list_path = @payment_record.order.is_purchase ? url_for(controller: "accounting", action: "orders", purchase: true) : url_for(controller: "accounting", action: "orders")
    
    respond_to do |format|
      if @payment_record.save
        @order.update_attributes(debt_date: @payment_record.debt_date)
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @payment_record, notice: 'Payment record was successfully created.' }
        format.json { render action: 'show', status: :created, location: @payment_record }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @payment_record.errors, status: :unprocessable_entity }
      end
    end    
  end
  
  def do_pay_tip
    @order = Order.find(payment_record_params[:order_id])
    
    authorize! :pay_tip, @order
    
    @payment_record = @order.payment_records.new(payment_record_params)
    @payment_record.accountant = current_user
    @payment_record.type_name = 'tip'
    
    list_path = @payment_record.order.is_purchase ? url_for(controller: "accounting", action: "orders", purchase: true) : url_for(controller: "accounting", action: "orders")
    
    respond_to do |format|
      if @payment_record.save
        format.html { redirect_to params[:tab_page].present? ? @payment_record : list_path, notice: 'Payment record was successfully created.' }
        format.json { render action: 'show', status: :created, location: @payment_record }
      else
        format.html { render action: 'pay_tip', tab_page: params[:tab_page] }
        format.json { render json: @payment_record.errors, status: :unprocessable_entity }
      end
    end    
  end
  
  # Legacy "New Pay/Recieve Record" form (single form with a direction
  # dropdown). Replaced by the two direction-specific forms; redirect to the
  # Pay one, which is what the dropdown defaulted to.
  def pay_custom
    redirect_to new_cash_pay_payment_records_path(tab_page: params[:tab_page])
  end

  # Legacy edit screen. The replacement derives the direction from the record
  # itself, so just hand over to it.
  def edit_pay_custom
    redirect_to edit_cash_record_payment_record_path(@payment_record, tab_page: params[:tab_page])
  end
  
  def do_pay_custom
    @payment_record = PaymentRecord.new(payment_record_params)
    @payment_record.accountant = current_user
    @payment_record.type_name = 'custom'
    
    if params[:is_recieved] == "false"
       @payment_record.amount = -@payment_record.amount.abs
    end
    
    
    respond_to do |format|
      if @payment_record.save
        format.html { redirect_to params[:tab_page].present? ? @payment_record : @payment_record, notice: 'Payment record was successfully created.' }
        format.json { render action: 'show', status: :created, location: @payment_record }
      else
        format.html { render action: 'pay_custom',  tab_page: params[:tab_page]}
        format.json { render json: @payment_record.errors, status: :unprocessable_entity }
      end
    end    
  end

  # ===========================================================================
  # Cash - Pay  /  Cash - Receive
  #
  # These replace the single "Custom Pay/Recieve" screen, whose form asked the
  # user to pick the direction from a dropdown that defaulted to Pay. Picking
  # the wrong option produced a record with the wrong amount sign, which then
  # flowed into the cash book, account book and statistics. Each direction now
  # has its own menu entry, its own list and its own form with no dropdown at
  # all, so the direction is decided by which screen you are on.
  # ===========================================================================

  def cash_pays
    @direction = 'pay'
    render_cash_index
  end

  def cash_receives
    @direction = 'receive'
    render_cash_index
  end

  def cash_datatable
    direction = PaymentRecord::CASH_DIRECTIONS.include?(params[:direction]) ? params[:direction] : 'pay'
    result = PaymentRecord.cash_datatable(params, direction)

    result[:items].each_with_index do |item, index|
      result[:result]['data'][index][result[:actions_col]] = render_cash_record_actions(item)
    end

    render json: result[:result]
  end

  def new_cash_pay
    build_cash_record('pay')
  end

  def new_cash_receive
    build_cash_record('receive')
  end

  def create_cash_pay
    persist_cash_record('pay')
  end

  def create_cash_receive
    persist_cash_record('receive')
  end

  def edit_cash_record
    @direction = @payment_record.cash_direction
    render_cash :edit_cash_record
  end

  def update_cash_record
    # Direction is intentionally NOT taken from the request: it is derived from
    # the persisted amount sign inside the model, so an edit can never flip a
    # Pay into a Receive.
    @direction = @payment_record.cash_direction

    if @payment_record.update(payment_record_params)
      redirect_to cash_index_path_for(@direction),
                  notice: "#{PaymentRecord.cash_direction_label(@direction)} record was successfully updated."
    else
      render_cash :edit_cash_record
    end
  end

  # PATCH/PUT /payment_records/1
  # PATCH/PUT /payment_records/1.json
  def update
    respond_to do |format|
      if @payment_record.update(payment_record_params)
        format.html { redirect_to custom_payments_payment_records_path, notice: 'Payment record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit',  tab_page: params[:tab_page] }
        format.json { render json: @payment_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_records/1
  # DELETE /payment_records/1.json
  def destroy
    @payment_record.destroy
    respond_to do |format|
      format.html { redirect_to custom_payments_payment_records_path }
      format.json { head :no_content }
    end
  end
  
  def trash
    list_path = @payment_record.order.is_purchase ? url_for(controller: "accounting", action: "orders", purchase: true) : url_for(controller: "accounting", action: "orders")
    
    respond_to do |format|
      if @payment_record.trash
        format.html { redirect_to "/home/close_tab", notice: 'Delivery was successfully trashed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to list_path, alert: 'Delivery was unsuccessfully trashed.' }
        format.json { head :no_content }
      end
    end
  end
  
  def statistics
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date.beginning_of_day
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
    
    @statistics = PaymentRecord.statistics(@from_date, @to_date, params)
    
    render layout: "content" if params[:tab_page].present?
  end
  
  def cash_book
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date.beginning_of_day
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_day
      @to_date =  DateTime.now.end_of_day
    end
    
    @statistics = PaymentRecord.cash_book(@from_date, @to_date, params)
    
    File.open('cash_book.yml', 'w') { |f| f.write(YAML.dump(@statistics)) }
    
    render layout: "content" if params[:tab_page].present?
  end
  
  def cash_book_xls
    @statistics = YAML.load(File.read('cash_book.yml'))
    workbook = RubyXL::Parser.parse('templates/account_book_template.xlsx')
    
    worksheet = workbook[0]
    
    # Begin
    worksheet[0][8].change_contents(@statistics[:begin])
    
    # End
    worksheet[4][8].change_contents(@statistics[:end])
    
    # Records
    @statistics[:datas].each do |data|
      worksheet.insert_row(3)
      p = data[:payment_record]
      
      worksheet[3][0].change_contents(p.paid_date.strftime("%Y-%m-%d"))
      worksheet[3][1].change_contents(p.description)
      worksheet[3][2].change_contents(p.note)
      worksheet[3][3].change_contents(p.printed_order_number)
      worksheet[3][4].change_contents(p.payment_method.name)
      worksheet[3][5].change_contents(p.bank_account.name) if p.bank_account.present?
      worksheet[3][6].change_contents(p.accountant.name)
      worksheet[3][7].change_contents(data[:recieve])
      worksheet[3][8].change_contents(data[:pay])
      
    end      
    
    send_data workbook.stream.string,
      filename: "cash_book.xlsx",
      disposition: 'attachment'
  end
  
  def account_book
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date.beginning_of_day
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_day
      @to_date =  DateTime.now.end_of_day
    end
    
    @statistics = PaymentRecord.account_book(@from_date, @to_date, params)
    
    File.open('account_book.yml', 'w') { |f| f.write(YAML.dump(@statistics)) }
    
    render layout: "content" if params[:tab_page].present?
  end
  
  def account_book_xls
    @statistics = YAML.load(File.read('account_book.yml'))
    workbook = RubyXL::Parser.parse('templates/account_book_template.xlsx')
    
    worksheet = workbook[0]
    
    # Begin
    worksheet[0][8].change_contents(@statistics[:begin])
    
    # End
    worksheet[4][8].change_contents(@statistics[:end])
    
    # Records
    @statistics[:datas].each do |data|
      worksheet.insert_row(3)
      p = data[:payment_record]
      
      worksheet[3][0].change_contents(p.paid_date.strftime("%Y-%m-%d"))
      worksheet[3][1].change_contents(p.description)
      worksheet[3][2].change_contents(p.note)
      worksheet[3][3].change_contents(p.printed_order_number)
      worksheet[3][4].change_contents(p.payment_method.name)
      worksheet[3][5].change_contents(p.bank_account.name) if p.bank_account.present?
      worksheet[3][6].change_contents(p.accountant.name)
      worksheet[3][7].change_contents(data[:recieve])
      worksheet[3][8].change_contents(data[:pay])
      
    end      
    
    send_data workbook.stream.string,
      filename: "account_book.xlsx",
      disposition: 'attachment'
  end
  
  def pay_commission
    @order = Order.find(params[:order_id])
        
    
    
    
    authorize! :pay_commission, @order
    @payment_record = PaymentRecord.new
    
    @payment_record.paid_person = @order.is_purchase ? @order.purchaser.name : @order.salesperson.name
    # @payment_record.paid_address = @order.is_purchase ? @order.purchaser.address : @order.salesperson.address    
    
    @payment_record.paid_date = (Time.now).strftime("%Y-%m-%d")
    
    render layout: "content" if params[:tab_page].present?
  end
  
  def do_pay_commission
    @order = Order.find(payment_record_params[:order_id])
    
    authorize! :pay_commission, @order
    
    @payment_record = @order.payment_records.new(payment_record_params)
    @payment_record.accountant = current_user
    @payment_record.type_name = 'commission'
    
    respond_to do |format|
      if @payment_record.save
        format.html { redirect_to params[:tab_page].present? ? @payment_record : statistics_commission_programs_path, notice: 'Payment record was successfully created.' }
        format.json { render action: 'show', status: :created, location: @payment_record }
      else
        format.html { render action: 'pay_commission',  tab_page: params[:tab_page] }
        format.json { render json: @payment_record.errors, status: :unprocessable_entity }
      end
    end    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_record
      @payment_record = PaymentRecord.find(params[:id])
    end

    # --- Cash - Pay / Cash - Receive helpers --------------------------------

    # The app renders inside a tabbed shell: opened as a tab it wants the bare
    # "content" layout, opened directly it wants the full chrome.
    #
    # Note `render layout: nil` DISABLES the layout in Rails rather than
    # falling back to the default, which silently drops the whole sidebar — so
    # the option is only passed when there really is a layout to force.
    def render_cash(view)
      if params[:tab_page].present?
        render view, layout: 'content'
      else
        render view
      end
    end

    def render_cash_index
      @cash_total = PaymentRecord.cash_total(@direction)
      render_cash :cash_index
    end

    def build_cash_record(direction)
      @direction      = direction
      @payment_record = PaymentRecord.new(type_name: PaymentRecord::CASH_TYPE)
      @payment_record.cash_direction_input = direction
      @payment_record.paid_date            = Time.now.strftime('%Y-%m-%d')

      render_cash :new_cash_record
    end

    def persist_cash_record(direction)
      @direction      = direction
      @payment_record = PaymentRecord.new(payment_record_params)
      @payment_record.accountant           = current_user
      @payment_record.type_name            = PaymentRecord::CASH_TYPE
      @payment_record.cash_direction_input = direction

      if @payment_record.save
        redirect_to @payment_record,
                    notice: "#{PaymentRecord.cash_direction_label(direction)} record was successfully created."
      else
        render_cash :new_cash_record
      end
    end

    def cash_index_path_for(direction)
      opts = { tab_page: params[:tab_page] }.reject { |_k, v| v.blank? }

      if direction.to_s == 'pay'
        cash_pays_payment_records_path(opts)
      else
        cash_receives_payment_records_path(opts)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_record_params
      params.require(:payment_record).permit(:bank_account_id, :is_recieved, :is_custom, :paid_date, :is_tip, :payment_method_id, :debt_date, :paid_person, :paid_address, :note, :debt_days, :amount, :order_id, :accountant_id)
    end
end
