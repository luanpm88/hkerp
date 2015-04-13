class AccountingController < ApplicationController
  
  def index
    authorize! :read, Order
    
    if params[:order].present?
      @month = params[:order]["order_date(2i)"].present? ? params[:order]["order_date(2i)"].to_i : 1
      @month_val  = params[:order]["order_date(2i)"].present? ? params[:order]["order_date(2i)"].to_i : nil
      
      date = Date.new params[:order]["order_date(1i)"].to_i, @month, params[:order]["order_date(3i)"].to_i
      
      @order = Order.new(:order_date => date)
    else
      @month = DateTime.now.month
      @month_val = @month
      @order = Order.new(:order_date => DateTime.now)
    end
    
    @statistics = Order.statistics(@order.order_date.year, @month_val, {supplier_id: params[:supplier_id], customer_id: params[:customer_id]})
  end
  
  def orders
    authorize! :read, Order
    
    if params[:purchase]
      @orders = Order.accounting_purchase_orders
    else
      @orders = Order.accounting_sales_orders
    end
  end
  
  def statistic_sales
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
    
    
    if params[:pdf] == "1"
        render  :pdf => "accounting_statistic_sales_#{@from_date.strftime("%Y-%m-%d")}_#{@to_date.strftime("%Y-%m-%d")}",
            :template => 'accounting/statistic_sales.pdf.erb',
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
    
    if params[:order].present?
      @month = params[:order]["order_date(2i)"].present? ? params[:order]["order_date(2i)"].to_i : 1
      @month_val  = params[:order]["order_date(2i)"].present? ? params[:order]["order_date(2i)"].to_i : nil
      
      date = Date.new params[:order]["order_date(1i)"].to_i, @month, params[:order]["order_date(3i)"].to_i
      
      @order = Order.new(:order_date => date)
    else
      @month = DateTime.now.month
      @month_val = @month
      @order = Order.new(:order_date => DateTime.now)
    end
    
    @supplier = params[:supplier_id].present? ? Contact.find(params[:supplier_id]) : nil
    @customer = params[:customer_id].present? ? Contact.find(params[:customer_id]) : nil
    
    @statistics = Order.statistics(@order.order_date.year, @month_val, {supplier_id: params[:supplier_id], customer_id: params[:customer_id]})
  end

  
end