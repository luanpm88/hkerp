class PaymentRecordsController < ApplicationController
  include ApplicationHelper
  
  load_and_authorize_resource :except => [:pay_commission, :do_pay_commission, :pay_tip, :do_pay_tip]
  
  before_action :set_payment_record, only: [:edit_pay_custom, :trash, :download_pdf, :show, :edit, :update, :destroy]

  # GET /payment_records
  # GET /payment_records.json
  def index
    @payment_records = PaymentRecord.all
  end
  
  def custom_payments
     render layout: "content" if params[:tab_page].present?
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
  
  def pay_custom
    @payment_record = PaymentRecord.new
    
    @payment_record.paid_date = (Time.now).strftime("%Y-%m-%d")
    @payment_record.is_recieved = false
    
    render layout: "content" if params[:tab_page].present?
  end
  
  def edit_pay_custom
    
    render layout: "content" if params[:tab_page].present?
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
        format.html { redirect_to list_path, notice: 'Delivery was successfully trashed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to list_path, alert: 'Delivery was unsuccessfully trashed.' }
        format.json { head :no_content }
      end
    end
  end
  
  def statistics
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
    
    @statistics = PaymentRecord.statistics(@from_date, @to_date, params)
    
    render layout: "content" if params[:tab_page].present?
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_record_params
      params.require(:payment_record).permit(:is_recieved, :is_custom, :paid_date, :is_tip, :payment_method_id, :debt_date, :paid_person, :paid_address, :note, :debt_days, :amount, :order_id, :accountant_id)
    end
end
