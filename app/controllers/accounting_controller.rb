class AccountingController < ApplicationController
  def index
    authorize! :read, Order
    
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
    
    @supplier = params[:supplier_id].present? ? Contact.find(params[:supplier_id]) : nil
    @customer = params[:customer_id].present? ? Contact.find(params[:customer_id]) : nil
    
    @statistics = Order.statistics(@from_date, @to_date, {supplier_id: params[:supplier_id], customer_id: params[:customer_id]})
    
    render layout: "content" if params[:tab_page].present?
  end
  
  def orders
    authorize! :read, Order
    
    if params[:purchase]
      @orders = Order.accounting_purchase_orders
    else
      @orders = Order.accounting_sales_orders
    end
  end
  
  def custom_payments
    @payment_records = PaymentRecord.custom_records
  end
  
  def statistic_sales
    authorize! :read, Order
    
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
    
    @supplier = params[:supplier_id].present? ? Contact.find(params[:supplier_id]) : nil
    @customer = params[:customer_id].present? ? Contact.find(params[:customer_id]) : nil
    @tip_contact = params[:tip_contact_id].present? ? Contact.find(params[:tip_contact_id]) : nil
    
    @paid_date_check = params[:paid_date_check].present? && params[:paid_date_check] == "1" ? true : false
    @paid_date_filter = @paid_date_check && params[:paid_date_filter].present? ? params[:paid_date_filter] : nil
    
    @statistics = Order.statistics(@from_date, @to_date, params)
    
    @orders = @statistics[:sell_orders]
    @total_notpaid = @statistics[:total_sell_with_vat_notpaid]
    @total_paid = @statistics[:total_sell_with_vat_paid]
    
    @total_tip_amount_paid = @statistics[:total_tip_amount_paid]
    @total_tip_amount_notpaid = @statistics[:total_tip_amount_notpaid]
    
    @total_PAD_paid = @statistics[:total_PAD_sell_paid]
    
    @total_fare = @statistics[:total_fare]
    @total_fare_vat = @statistics[:total_fare_vat]
    
    @total_with_vat = @statistics[:total_sell_with_vat]
    
    @total = @statistics[:total_sell]
    @total_cost = @statistics[:total_cost]
    
    if params[:pdf] == "1"
      tip = params[:tip] == "1" ? "_tip" : ""
        render  :pdf => "accounting_statistic_sales#{tip}_#{@from_date.strftime("%Y-%m-%d")}_#{@to_date.strftime("%Y-%m-%d")}",
            :template => "accounting/statistic_sales#{tip}.pdf.erb",
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
  end
  
  def statistic_purchase
    authorize! :read, Order
    
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
    
    @supplier = params[:supplier_id].present? ? Contact.find(params[:supplier_id]) : nil
    @customer = params[:customer_id].present? ? Contact.find(params[:customer_id]) : nil
    
    @paid_date_check = params[:paid_date_check].present? && params[:paid_date_check] == "1" ? true : false
    @paid_date_filter = @paid_date_check && params[:paid_date_filter].present? ? params[:paid_date_filter] : nil
    
    @statistics = Order.statistics(@from_date, @to_date, params)
    
    @orders = @statistics[:buy_orders]
    @total_notpaid = @statistics[:total_buy_with_vat_notpaid]
    @total_paid = @statistics[:total_buy_with_vat_paid]
    
    @total_PAD_paid = @statistics[:total_PAD_buy_paid]
    
    @total_with_vat = @statistics[:total_buy_with_vat]
    
    
    if params[:pdf] == "1"
        render  :pdf => "accounting_statistic_purchase_#{@from_date.strftime("%Y-%m-%d")}_#{@to_date.strftime("%Y-%m-%d")}",
            :template => 'accounting/statistic_purchase.pdf.erb',
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
  end
  
  

  
end