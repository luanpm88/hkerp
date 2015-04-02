class AccountingController < ApplicationController
  
  def index
    authorize! :read, Order
    
    if params[:order].present?
      @month = params[:order]["order_date(2i)"].present? ? params[:order]["order_date(2i)"].to_i : 1
      @month_val  = params[:order]["order_date(2i)"].present? ? params[:order]["order_date(2i)"].to_i : nil
      
      date = Date.new params[:order]["order_date(1i)"].to_i, @month, params[:order]["order_date(3i)"].to_i
      
      @order = Order.new(:order_date => date)
    else
      @month_val = DateTime.now.month
      @order = Order.new(:order_date => DateTime.now)
    end
    
    @statistics = Order.statistics(@order.order_date.year, @month_val)
  end
  
  def orders
    authorize! :read, Order
    
    if params[:purchase]
      @orders = Order.get_confirmed_purchase_orders
    else
      @orders = Order.get_confirmed_sales_orders
    end
  end
  
end