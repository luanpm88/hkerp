class AccountingController < ApplicationController
  
  def index
    authorize! :read_statistics, Order
    
    if params[:order].present?
      @month = params[:order]["order_date(2i)"].present? ? params[:order]["order_date(2i)"].to_i : 1
      @month_val  = params[:order]["order_date(2i)"].present? ? params[:order]["order_date(2i)"].to_i : nil
      
      date = Date.new params[:order]["order_date(1i)"].to_i, @month, params[:order]["order_date(3i)"].to_i
      
      @order = Order.new(:order_date => date)
    else
      @order = Order.new(:order_date => DateTime.now)
    end
    
    @statistics = Order.statistics(@order.order_date.year, @month_val)
  end
  
end