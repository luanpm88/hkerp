class AccountingController < ApplicationController
  def order_export
    require 'rubyXL/convenience_methods/worksheet'
    require 'rubyXL/convenience_methods/cell'

    @params = YAML.load(File.read('report/report_' + params["report_hook"] + '.yml'))
    items = Order.get_query(@params, current_user)
    
    
    
    workbook = RubyXL::Parser.parse('templates/order_report.xlsx')
    
    worksheet = workbook[0]
    
    ## Begin
    #worksheet[0][8].change_contents(@statistics[:begin])
    #
    ## End
    #worksheet[4][8].change_contents(@statistics[:end])
    
    # Records
    items.reverse.each do |item|      
      item.order_details.each do |od|
        worksheet.insert_row(2)
        worksheet[2][3].change_contents(od.product_name)
        worksheet[2][8].change_contents(od.total)
        worksheet[2][9].change_contents(od.vat_amount)
        worksheet[2][10].change_contents(od.total_vat)
      end
      
      worksheet.insert_row(2)
      if item.is_purchase
        name_col = item.supplier.short_name
      else
        name_col = item.customer.short_name
      end
      
      if !item.is_purchase
        staff_col = item.salesperson.name
      else
        staff_col = item.purchaser.name
      end
      worksheet[2][0].change_contents(item.quotation_code)
      worksheet[2][1].change_contents(item.customer_po)
      worksheet[2][2].change_contents(item.printed_order_number)
      worksheet[2][3].change_contents(name_col)
      worksheet[2][4].change_contents(staff_col)
      worksheet[2][5].change_contents(item.order_date_formatted)
      worksheet[2][6].change_contents(item.is_debt || item.is_out_of_date ? item.debt_remain_days.to_s+' days' : "")
      worksheet[2][7].change_contents(item.order_status_name)
      worksheet[2][8].change_contents(item.total)
      worksheet[2][9].change_contents(item.vat_amount)
      worksheet[2][10].change_contents(item.total_vat)
      worksheet[2][11].change_contents(item.paid_amount)      
      worksheet[2][12].change_contents(item.remain_amount)
      
      
      
    end      
    
    send_data workbook.stream.string,
      filename: "order_export.xlsx",
      disposition: 'attachment'
  end
  
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
    
    @report_hook = Time.now.to_i.to_s + '_' + current_user.id.to_s
    
    render layout: "content" if params[:tab_page].present?
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
    else
      render layout: "content" if params[:tab_page].present?
    end
  end
  
  def statistic_sales_custom
    authorize! :read, Order
    
	@min_order_detail_price = 1000000
	if params[:min_order_detail_price].present?
		@min_order_detail_price = params[:min_order_detail_price].gsub(",", "")
	end
	
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
    
    @statistics = Order.statistics_custom(@from_date, @to_date, params, @min_order_detail_price)
    
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
        render  :pdf => "accounting_statistic_sales_custom#{tip}_#{@from_date.strftime("%Y-%m-%d")}_#{@to_date.strftime("%Y-%m-%d")}",
            :template => "accounting/statistic_sales_custom#{tip}.pdf.erb",
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
    else
      render layout: "content" if params[:tab_page].present?
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
    else
      render layout: "content" if params[:tab_page].present?
    end
  end
  
  def statistic_stock
    authorize! :statistic_stock, Product
    
    @statistics = Product.stock_statistic
    
    render layout: "content" if params[:tab_page].present?
  end

  def export
    require 'rubyXL/convenience_methods/worksheet'
    require 'rubyXL/convenience_methods/cell'

    @from_date = params[:from_date].present? ? params[:from_date].to_date : DateTime.now.beginning_of_month
    @to_date =  params[:to_date].present? ? params[:to_date].to_date.end_of_day : DateTime.now
    
    if request.post?      
      @supplier = params[:supplier_id].present? ? Contact.find(params[:supplier_id]) : nil
      @customer = params[:customer_id].present? ? Contact.find(params[:customer_id]) : nil
      
      @statistics = Order.statistics(@from_date, @to_date, params)
      
      workbook = RubyXL::Parser.parse('templates/order_export_template.xlsx')      
      worksheet = workbook[0]      
      # Begin
      worksheet[2][0].change_contents("Từ #{@from_date.strftime("%Y-%m-%d")} Đến #{@to_date.strftime("%Y-%m-%d")}")
      
      if params[:sales].present?
        @orders = @statistics[:sell_orders]
        
        worksheet[1][0].change_contents("BẢNG KÊ BÁN RA")
        worksheet[3][5].change_contents("Khách hàng")
        
        # End
        worksheet[6][8].change_contents(@statistics[:total_sell])
        worksheet[6][10].change_contents(@statistics[:total_vat_sell])
        worksheet[6][11].change_contents(@statistics[:total_sell_with_vat])
        
        # Records
        @orders.each do |order|
          order.order_details.each do |order_detail|
            worksheet.insert_row(5)
            
            worksheet[5][0].change_contents(order.quotation_code)
            # worksheet[5][1].change_contents(order.printed_order_number)
            # worksheet[5][2].change_contents(order.printed_order_number)
            worksheet[5][3].change_contents(order.printed_order_number)
            worksheet[5][4].change_contents(order.order_date.strftime("%Y-%m-%d"))
            worksheet[5][5].change_contents(order.customer.short_name)
            worksheet[5][6].change_contents(order.customer.tax_code)
            worksheet[5][7].change_contents(order_detail.product_name)
            worksheet[5][8].change_contents(order_detail.total)
            worksheet[5][9].change_contents(order.tax.rate)
            worksheet[5][10].change_contents(order_detail.vat_amount)
            worksheet[5][11].change_contents(order_detail.total_vat)
          end
        end      
        
        send_data workbook.stream.string,
          filename: "sales.xlsx",
          disposition: 'attachment'
      elsif params[:purchase].present?
        @orders = @statistics[:buy_orders]
        
        worksheet[1][0].change_contents("BẢNG KÊ MUA VÀO")
        worksheet[3][5].change_contents("Nhà CC")
        
        # End
        worksheet[6][8].change_contents(@statistics[:total_buy])
        worksheet[6][10].change_contents(@statistics[:total_vat_buy])
        worksheet[6][11].change_contents(@statistics[:total_buy_with_vat])
        
        # Records
        @orders.each do |order|
          order.order_details.each do |order_detail|
            worksheet.insert_row(5)
            
            worksheet[5][0].change_contents(order.quotation_code)
            # worksheet[5][1].change_contents(order.printed_order_number)
            # worksheet[5][2].change_contents(order.printed_order_number)
            worksheet[5][3].change_contents(order.printed_order_number)
            worksheet[5][4].change_contents(order.order_date.strftime("%Y-%m-%d"))
            worksheet[5][5].change_contents(order.supplier.short_name)
            worksheet[5][6].change_contents(order.supplier.tax_code)
            worksheet[5][7].change_contents(order_detail.product_name)
            worksheet[5][8].change_contents(order_detail.total)
            worksheet[5][9].change_contents(order.tax.rate)
            worksheet[5][10].change_contents(order_detail.vat_amount)
            worksheet[5][11].change_contents(order_detail.total_vat)
          end
        end      
        
        send_data workbook.stream.string,
          filename: "purchase.xlsx",
          disposition: 'attachment'        
      elsif params[:invoice].present?
        workbook = RubyXL::Parser.parse('templates/invoices_import.xlsx')      
        worksheet = workbook[0]      
        # Begin
        @orders = @statistics[:sell_orders]

        # Records
        count = 0
        @orders.each_with_index do |order,index|
          order.order_details.each do |order_detail|
            current_row = 6+count
            
            worksheet.insert_row(6+count)
            
            worksheet[current_row][0].change_contents(count+1)
            worksheet[current_row][1].change_contents(order.quotation_code)
            
            content = order_detail.product_name
            #content += "\r\nPO: " + order.customer_po if order.customer_po.present?
            worksheet[current_row][2].change_contents(content)            
            worksheet[current_row][3].change_contents(order_detail.unit)
            worksheet[current_row][4].change_contents(order_detail.quantity)
            worksheet[current_row][5].change_contents(order_detail.price)
            worksheet[current_row][6].change_contents(order_detail.total)
            worksheet[current_row][7].change_contents(order.tax.rate/100)
            worksheet[current_row][8].change_contents(order_detail.vat_amount)
            worksheet[current_row][9].change_contents(order.order_date.strftime("%d/%m/%Y"))
            worksheet[current_row][10].change_contents(order.buyer_name)
            worksheet[current_row][11].change_contents(order.buyer_company)
            worksheet[current_row][12].change_contents(order.buyer_tax_code)
            worksheet[current_row][13].change_contents(order.buyer_address)
            worksheet[current_row][14].change_contents(order.customer.account_number)
            worksheet[current_row][15].change_contents((!order.payment_method.nil? ? order.payment_method.print_name : "TM/CK"))
            #worksheet[5][3].change_contents(order.printed_order_number)
            #worksheet[5][4].change_contents(order.order_date.strftime("%Y-%m-%d"))
            #worksheet[5][5].change_contents(order.customer.short_name)
            #worksheet[5][6].change_contents(order.customer.tax_code)
            #worksheet[5][7].change_contents(order_detail.product_name)
            #worksheet[5][8].change_contents(order_detail.total)
            #worksheet[5][9].change_contents(order.tax.rate)
            #worksheet[5][10].change_contents(order_detail.vat_amount)
            #worksheet[5][11].change_contents(order_detail.total_vat)
            
            count += 1
          end
        end
        
        worksheet.delete_row(5)
        
        send_data workbook.stream.string,
          filename: "invoices.xlsx",
          disposition: 'attachment'
      end
    end
  end

  def sales_by_category_export
    require 'rubyXL/convenience_methods/worksheet'
    require 'rubyXL/convenience_methods/cell'

    @from_date = params[:from_date].present? ? params[:from_date].to_date : DateTime.now.beginning_of_month
    @to_date =  params[:to_date].present? ? params[:to_date].to_date.end_of_day : DateTime.now
    
    workbook = RubyXL::Parser.parse('templates/sales_by_category_export.xlsx')      
    groups = [
      {worksheet: workbook[0], data: Order.sales_by_category(@from_date, @to_date, {without_kddi: true})},
      {worksheet: workbook[1], data: Order.sales_by_category(@from_date, @to_date)},
    ]

    groups.each do |group|
      worksheet = group[:worksheet]
      data = group[:data]

      # dates
      worksheet[2][0].change_contents("Từ #{@from_date.strftime("%Y-%m-%d")} Đến #{@to_date.strftime("%Y-%m-%d")}")

      #
      worksheet[3][1].change_contents(data[:total])
      worksheet[3][2].change_contents(data[:quantity])
      data[:records].each_with_index do |record,index|
        row = index + 5

        worksheet[row][0].change_contents(record[:category].to_s)
        worksheet[row][1].change_contents(record[:total])
        worksheet[row][2].change_contents(record[:quantity])
      end
    end
    
    send_data workbook.stream.string,
      filename: "sales_by_category_export_#{@from_date.strftime("%Y-%m-%d")}_#{@to_date.strftime("%Y-%m-%d")}.xlsx",
      disposition: 'attachment'
  end
  
end