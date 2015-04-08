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