class ProductsController < ApplicationController
  include ApplicationHelper
  
  load_and_authorize_resource :except => [
    :ajax_new,
    :ajax_show,
    :ajax_create,
    :datatable,
    :erp_connector,
    :erp_categories_dataselect,
    :erp_get_info,
    :erp_price_update,
    :erp_set_imported,
    :erp_set_sold_out,
    :erp_set_cache_thcn_url,
    :erp_set_cache_thcn_properties,
    :erp_manufacturers_dataselect
  ]
  protect_from_forgery :except  => [:erp_connector]
  before_action :set_product, only: [:quick_update_price, :unsuspend, :suspend, :product_log, :ajax_product_prices, :trash, :do_combine_parts, :combine_parts, :do_update_price, :update_price, :show, :edit, :update, :destroy, :ajax_show]

  # GET /products
  # GET /products.json
  def index
    @products = Product.order("name").all

    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: Product.full_text_search(params[:q])
      }
    end
  end

  def datatable
    authorize! :read, Product

    result = Product.datatable(params, current_user)

    result[:items].each_with_index do |item, index|


      actions = '<div class="text-right" style="display: flex;align-items: center;justify-content: right;">
        '+view_context.link_to('<i class="icon-pencil"></i>'.html_safe, edit_product_path(id: item.id, tab_page: 1), psrc: products_url(tab_page: 1), title: "Edit: #{item.display_name}", class: "tab_page btn btn-mini btn-white")+'<div class="btn-group actions">
                    <button style="margin:0" class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown"><span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu dropdown-menu-right">'

      if can? :update, item
        actions += '<li>'+view_context.link_to("Edit", edit_product_path(id: item.id, tab_page: 1), psrc: products_url(tab_page: 1), title: "Edit: #{item.display_name}", class: "tab_page")+'</li>'
      end
      if can? :create, ProductStockUpdate
        actions += '<li>'+view_context.link_to("Update Stock (Nhập Kho)", new_product_stock_update_path(product_id: item.id, tab_page: 1), psrc: products_url(tab_page: 1), title: "Update Stock: #{item.display_name}", class: "tab_page")+'</li>'
      end
      if can? :combine_parts, item
        actions += '<li>'+view_context.link_to("Combine Parts", {controller: "combinations", action: "new", product_id: item.id, tab_page: 1}, psrc: products_url(tab_page: 1), title: "Combine Parts: #{item.display_name}", class: "tab_page")+'</li>'
      end
      if can? :de_combine_parts, item
        actions += '<li>'+view_context.link_to("De-combine Parts", {controller: "combinations", action: "new", product_id: item.id, combined: false, tab_page: 1}, psrc: products_url(tab_page: 1), title: "De-Combine Parts: #{item.display_name}", class: "tab_page")+'</li>'
      end
      if can? :product_log, item
        actions += '<li>'+view_context.link_to("<i class=\"icon-time\"></i> Product Logs".html_safe, {controller: "products", action: "product_log", id: item.id, tab_page: 1}, title: "Product Logs: #{item.display_name}", target: "_blank", class: "tab_page")+'</li>'
      end
      if can? :ajax_product_prices, item
        actions += '<li>'+item.price_history_link(false)+'</li>'
      end
      if can? :update_price, item
        actions += '<li>'+view_context.link_to("Update Price", {controller: "products", action: "update_price", id: item.id, tab_page: 1}, psrc: products_url(tab_page: 1), title: "Update Price: #{item.display_name}", class: "tab_page")+'</li>'
      end
      if can? :update_price, item
        actions += '<li>'+view_context.link_to("Refresh Price", {controller: "products", action: "refresh_price", id: item.id, tab_page: 1}, psrc: products_url(tab_page: 1), title: "Refresh Price: #{item.display_name}", class: "list_ajax_action")+'</li>'
      end
      if can? :suspend, item
        actions += '<li>'+view_context.link_to("Suspend", suspend_products_path(id: item.id, tab_page: 1), method_data: 'patch', psrc: products_url(tab_page: 1), title: "Suspend: #{item.display_name}", class: "list_ajax_action")+'</li>'
      end
      if can? :unsuspend, item
        actions += '<li>'+view_context.link_to("Un-suspend", unsuspend_products_path(id: item.id, tab_page: 1), method_data: 'patch', psrc: products_url(tab_page: 1), title: "Suspend: #{item.display_name}", class: "list_ajax_action")+'</li>'
      end
      if can? :trash, item
        actions += '<li>'+view_context.link_to('<i class="icon-trash"></i> Trash'.html_safe, {controller: "products", action: "trash", id: item.id, tab_page: 1}, method: :patch)+'</li>'
      end
      if can? :un_trash, item
        actions += '<li>'+view_context.link_to('<i class="icon-trash"></i> Un-Trash'.html_safe, {controller: "products", action: "un_trash", id: item.id, tab_page: 1}, method: :patch)+'</li>'
      end


      actions += '</ul></div></div>'

      result[:result]["data"][index][result[:actions_col]] = actions if result[:actions_col] != 0
    end

    render json: result[:result]
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new

    (1..10).each do |i|
      @product.product_parts.build
    end

    @product_images = []
    (1..12).each do |i|
      @product_images << @product.product_images.build(display_order: i)
    end

     render layout: "content" if params[:tab_page].present?
  end

  # GET /products/1/edit
  def edit
    (1..(10-@product.product_parts.count)).each do |i|
      @product.product_parts.build
    end

    @product_images = @product.product_images.order(:display_order)
    (1..(12-@product.product_images.count)).each do |i|
      @product_images << @product.product_images.build(display_order: i+@product.product_images.count)
    end

    render layout: "content" if params[:tab_page].present?
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)
    @product.user = current_user

    (1..(10-@product.product_parts.count)).each do |i|
      @product.product_parts.build
    end

    @product_images = []
    (1..(12-@product.product_images.count)).each do |i|
      @product_images << @product.product_images.build(display_order: i+@product.product_images.count)
    end

    respond_to do |format|
      if @product.save
        @product.update_price(params["product_prices"], current_user) if can? :update_public_price, @product

        format.html { redirect_to params[:tab_page].present? ? {action: "edit", id: @product.id, tab_page: 1} : edit_product_path(@product), notice: 'Product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'new', tab_page: [:tab_page] }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    p product_params


    respond_to do |format|
      if @product.update(product_params)
        @product.update_price(params["product_prices"], current_user) if can? :update_public_price, @product
        format.html { redirect_to params[:tab_page].present? ? {action: "edit", id: @product.id, tab_page: 1} : edit_product_path(@product), notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: [:tab_page] }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def ajax_show
    authorize! :read, Product

    price = params[:purchase].present? ? @product.product_price.supplier_price : @product.product_price.price

    @data = Hash[display_name: @product.display_name,
                 product_price_id: @product.product_prices.count > 0 ? @product.product_price.id : 0,
                 price: price,
                 product: @product,
                 order_supplier_history: @product.order_supplier_history(current_user),
                 product_image: "<h4>Image</h4><div class=\"text-center\"><img src=\"#{@product.image(:thumb)}\" width=\"auto\" /></div>",
                 note: "<h4>Note</h4>"+@product.note.to_s
            ]
    render :json => @data
  end

  def ajax_new
    authorize! :create, Product

    @product = Product.new

    render :layout => nil
  end

  def ajax_create
    authorize! :create, Product

    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        @product.update_price(params["product_prices"], current_user) if can? :update_price, @product
        format.html { render action: 'ajax_show', :layout => nil, :id => @product.id }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'ajax_new', :layout => nil }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def sales_delivery
    @orders = Order.get_sales_orders_with_delivery
  end

  def update_price
    render layout: "content" if params[:tab_page].present?
  end

  def do_update_price
    respond_to do |format|
      if @product.update_price(params["product_prices"], current_user)
        format.html { redirect_to params[:tab_page].present? ? {action: "update_price", id: @product.id, tab_page: 1} : products_url, notice: 'Product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'new', tab_page: [:tab_page] }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def trash
    if @product.calculated_stock != 0
      render text: 'Stock quantity != 0. Can not delete'
    else
      respond_to do |format|
        if @product.trash
          format.html { redirect_to params[:tab_page].present? ? products_url(tab_page: 1) : products_url, notice: 'Product was successfully trashed.' }
          format.json { render action: 'show', status: :created, location: @product }
        else
          format.html { redirect_to params[:tab_page].present? ? products_url(tab_page: 1) : products_url, alert: 'Product was unsuccessfully trashed.' }
          format.json { render action: 'show', status: :created, location: @product }
        end
      end
    end
  end

  def suspend
    if @product.update_column(:suspended, true)
      render text: 'Product was successfully suspended.'
    else
      render text: 'Product was unsuccessfully suspended.'
    end
  end

  def unsuspend
    if @product.update_column(:suspended, false)
      render text: 'Product was successfully suspended.'
    else
      render text: 'Product was unsuccessfully suspended.'
    end
  end

  def un_trash
    respond_to do |format|
      if @product.un_trash
        format.html { redirect_to params[:tab_page].present? ? products_url(tab_page: 1) : products_url, notice: 'Product was successfully trashed.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { redirect_to params[:tab_page].present? ? products_url(tab_page: 1) : products_url, alert: 'Product was unsuccessfully trashed.' }
        format.json { render action: 'show', status: :created, location: @product }
      end
    end
  end

  def statistics
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date.beginning_of_day
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now.end_of_day
    end

    @products = Product.statistics(@from_date, @to_date).limit(1)

    if params[:pdf] == "1" and params[:price] == "1"
      @products = @products.where('stock > ?', 0)
        render  :pdf => "products_statistics_#{@from_date.strftime("%Y-%m-%d")}_#{@to_date.strftime("%Y-%m-%d")}",
            :template => 'products/statistics_with_prices.pdf.erb',
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
    elsif params[:pdf] == "1"      
      render  :pdf => "products_statistics_#{@from_date.strftime("%Y-%m-%d")}_#{@to_date.strftime("%Y-%m-%d")}",
          :template => 'products/statistics.pdf.erb',
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
    elsif params[:excel] == "1" and params[:price] == "1"
      @products = @products.where('stock > ?', 0)

      require 'rubyXL/convenience_methods/worksheet'
      require 'rubyXL/convenience_methods/cell'

      workbook = RubyXL::Parser.parse('templates/RemainStockWithPrices.xlsx')      
      worksheet = workbook[0]      
      # Begin
      worksheet[0][0].change_contents("Tồn kho đến ngày #{@to_date.strftime("%Y-%m-%d")}")
      
      count = 1
			cat = nil
			iIndex = 3
			
			total = {
        b: 0,
        b_price: 0,
        purchase: 0,
        sales: 0,
        combine: 0,
        io: 0,
        e: 0,
        e_price: 0,
      }
			
			# @products = @products.where('stock > 0') if params[:remain].present?
      @products.each do |product|
          e = product.calculated_stock(@to_date)    
        
        if params[:remain].nil? || (!params[:remain].nil? && (e > 0 || purchase > 0 || sales > 0 || combine > 0 || io > 0))
    
          # insert product
          worksheet.insert_row(iIndex)
          worksheet[iIndex][0].change_contents(count)
          worksheet[iIndex][1].change_contents(product.category.name)
          worksheet[iIndex][2].change_contents(product.display_name_without_category)
          worksheet[iIndex][3].change_contents(e)
          worksheet[iIndex][4].change_contents(product.product_price.supplier_price)
          worksheet[iIndex][5].change_contents(product.product_price.price)
          
          # total
          total[:e] += e
          
          # increment count
          count += 1
          iIndex += 1
        end
      end
      
      worksheet.delete_row(2)
      worksheet.delete_row(iIndex-1)
      
      # total
      worksheet[0][3].change_contents(total[:e])
      
      send_data workbook.stream.string,
          filename: "stocks.xlsx",
          disposition: 'attachment'
    elsif params[:excel] == "1"
      require 'rubyXL/convenience_methods/worksheet'
      require 'rubyXL/convenience_methods/cell'

      workbook = RubyXL::Parser.parse('templates/RemainStock.xlsx')      
      worksheet = workbook[0]      
      # Begin
      worksheet[0][0].change_contents("Tồn kho từ #{@from_date.strftime("%Y-%m-%d")} đến #{@to_date.strftime("%Y-%m-%d")}")
      
      count = 1
			cat = nil
			iIndex = 3
			
			total = {
        b: 0,
        b_price: 0,
        purchase: 0,
        sales: 0,
        combine: 0,
        io: 0,
        e: 0,
        e_price: 0,
      }
			
			# @products = @products.where('stock > 0') if params[:remain].present?
      @products.each do |product|
          e = product.calculated_stock(@to_date)
          
          purchase = product.import_count(@from_date, @to_date)
          sales = product.export_count(@from_date, @to_date)
          combine = product.combination_count(@from_date, @to_date)
          io = product.stock_update_count(@from_date, @to_date)          
        
        if params[:remain].nil? || (!params[:remain].nil? && (e > 0 || purchase > 0 || sales > 0 || combine > 0 || io > 0))
          b = product.calculated_stock((@from_date - 1.day).end_of_day)
          e_price = product.cost_price(@from_date).to_f * e
          b_price = product.cost_price(@from_date).to_f * b
          
          # insert product
          worksheet.insert_row(iIndex)
          worksheet[iIndex][0].change_contents(count)
          worksheet[iIndex][1].change_contents(product.category.name)
          worksheet[iIndex][2].change_contents(product.display_name_without_category)
          worksheet[iIndex][3].change_contents(b)
          worksheet[iIndex][4].change_contents(b_price)
          worksheet[iIndex][5].change_contents(purchase)
          worksheet[iIndex][6].change_contents(-sales)
          worksheet[iIndex][7].change_contents(combine)
          worksheet[iIndex][8].change_contents(io)
          worksheet[iIndex][9].change_contents(e)
          worksheet[iIndex][10].change_contents(e_price)
          
          # total
          total[:b_price] += b_price
          total[:b] += b
          total[:purchase] += purchase
          total[:sales] += sales
          total[:combine] += combine
          total[:io] += io
          total[:e] += e
          total[:e_price] += e_price
          
          # increment count
          count += 1
          iIndex += 1
        end
      end
      
      worksheet.delete_row(2)
      worksheet.delete_row(iIndex-1)
      
      # total
      worksheet[0][3].change_contents(total[:b])
      worksheet[0][4].change_contents(total[:b_price])
      worksheet[0][5].change_contents(total[:purchase])
      worksheet[0][6].change_contents(total[:sales])
      worksheet[0][7].change_contents(total[:combine])
      worksheet[0][8].change_contents(total[:io])
      worksheet[0][9].change_contents(total[:e])
      worksheet[0][10].change_contents(total[:e_price])
      
      send_data workbook.stream.string,
          filename: "stocks.xlsx",
          disposition: 'attachment'
    end
  end

  def ajax_product_prices
    render layout: nil
  end

  def product_log
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end

    @history = @product.product_log(@from_date, @to_date, current_user)

    render layout: "content" if params[:tab_page].present?
  end

  def warranty_check
    if params[:serial_number].present?
      @products = Product.find_by_serial_number(params[:serial_number].strip)
    end

    render layout: "content" if params[:tab_page].present?
  end

  def export_to_excel
    @products = Product.where(status: 1).where("stock > 0").order("stock DESC")

    respond_to do |format|
      format.html
      format.xls
    end
  end

  def erp_connector
    per_page = 20
    page = params[:page].present? ? params[:page].to_i : 0

    products = Product.joins(:categories).joins(:manufacturer)

    #FILTERS
    and_conds = []

    #All data
    data = params['data'].present? ? JSON.parse(params['data']) : {}

    #keywords
    if data["keywords"].present?
      data["keywords"].each do |kw|
        or_conds = []
        kw[1].each do |cond|
          #or_conds << "LOWER(#{cond[1]["name"]}) LIKE '%#{cond[1]["value"].downcase.strip}%'"
          keyword = cond[1]["value"]
          #or_conds << "(LOWER(products.cache_search) LIKE '%#{k.strip.downcase}%' OR products.cache_search LIKE '%#{k.strip}%')" if k.strip.present?
          
          and_conds_2 = []
          keyword.split(" ").each do |k|
            and_conds_2 << "(LOWER(products.cache_search) LIKE '%#{k.strip.downcase}%' OR products.cache_search LIKE '%#{k.strip}%')" if k.strip.present?
          end
          
          or_conds << '('+and_conds_2.join(' AND ')+')'
        end
        and_conds << '('+or_conds.join(' OR ')+')'
      end
    end
    
    #filter
    trashed = false
    if data["filters"].present?
      data["filters"].each do |kw|
        or_conds = []
        kw[1].each do |cond|
          if cond[1]["name"] == 'stock'
            or_conds << "(products.stock > 0)"
          elsif cond[1]["name"] == 'out_of_date'
            or_conds << "(products.cache_search) LIKE '%[out_of_date]%'"
          elsif cond[1]["name"] == 'not_out_of_date'
            or_conds << "(products.cache_search) NOT LIKE '%[out_of_date]%'"
          elsif cond[1]["name"] == 'products.erp_price_updated'
            or_conds << "(#{cond[1]["name"]} = '#{cond[1]["value"]}' AND products.erp_imported = true)"
          else
            or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
          end
    
          if cond[1]["name"] == 'products.status'
            trashed = true
          end
        end
        and_conds << '('+or_conds.join(' OR ')+')'
      end
    end
    
    if !trashed
      products = products.where(status: 1)
    end

    # conditions
    products = products.where(and_conds.join(' AND ')) if !and_conds.empty?

    # order
      if data["sort_by"].present?
        order = data["sort_by"]
        order += " #{data["sort_direction"]}" if data["sort_direction"].present?

        products = products.order(order)
      end

    render json: {
      "products": (products.offset(per_page*page).limit(per_page).map {|item| {
        "id": item.id,
        "display_name": item.display_name,
        "name": item.name,
        "fixed_name": item.fixed_name,
        "product_code": item.product_code,
        "price": item.get_web_price,
        "listed_price": item.listed_price,
        "description": item.description,
        "stock": item.calculated_stock,
        "unit": item.unit,
        "suspended": item.suspended,
        "out_of_date": item.out_of_date,
        "warranty": item.warranty,
        "status": item.status,
        "discount_percent": item.discount_percent,
      }}),
      "total": products.count('products.id'),
      "per_page": per_page
    }
  end

  def erp_categories_dataselect
    query = Category.all
    keyword = params[:keyword]

    if keyword.present?
      keyword = keyword.strip.downcase
      query = query.where('LOWER(name) LIKE ?', "%#{keyword}%")
    end

    query = query.limit(15).map{|category| {value: category.id, text: category.name} }

    render json: query
  end

  def erp_manufacturers_dataselect
    query = Manufacturer.all
    keyword = params[:keyword]

    if keyword.present?
      keyword = keyword.strip.downcase
      query = query.where('LOWER(name) LIKE ?', "%#{keyword}%")
    end

    query = query.limit(8).map{|manu| {value: manu.id, text: manu.name} }

    render json: query
  end

  def erp_get_info
    product = Product.find(params[:id])

    render json: {
      "id": product.id,
      "display_name": product.display_name,
      "name": product.display_name,
      "product_code": product.product_code,
      "price": product.get_web_price,
      "description": product.description,
      "stock": product.calculated_stock,
      "unit": product.unit,
      "warranty": product.warranty,
      "listed_price": product.listed_price,
      "fixed_name": product.fixed_name,
      "discount_percent": product.discount_percent,
    }
  end

  def erp_price_update
    product = Product.find(params[:id])

    product.update_column(:erp_price_updated, true)
  end

  def erp_set_imported
    product = Product.find(params[:id])
    value = true
    value = false if params[:value].present? and params[:value] == 'false'
    product.update_column(:erp_imported, value)
  end

  def erp_set_sold_out
    product = Product.find(params[:id])
    product.update_column(:erp_sold_out, params[:value])
  end

  def erp_set_cache_thcn_url
    product = Product.find(params[:id])
    product.update_column(:cache_thcn_url, params[:url])
  end

  def quick_update_price
    @product.update_price(params["product_prices"], current_user)

    render json: {
      price_col: @product.price_col(current_user),
      price_status: @product.price_status
    }
  end

  def export
    @products = Product.filter(params, current_user)

    respond_to do |format|
      format.html
      format.xls
    end
  end

  def erp_set_cache_thcn_properties
    product = Product.find(params[:id])
    product.update_column(:cache_thcn_properties, params[:data])

    render nothing: true
  end
  
  # refresh price, make price updated
  def refresh_price
    product = Product.find(params[:id])
    
    if product.refresh_price(current_user)
      render text: 'Product price was successfully refreshed.'
    else
      render text: 'Product price unsuccessfully refreshed.'
    end
  end
  
  # BHPhotoVideo connector
  def bhpv_connector
    @list = params[:url].present? ? Product.bhpv_list(url: params[:url]) : []
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:listed_price, :fixed_name, :is_manual_cost, :in_use, :is_manual_price_update, :web_price, :no_price, :intro, :short_intro, :note, :serial_numbers, :stock, :name, :description, :price, :product_code, :manufacturer_id, :unit, :warranty,
                                      :category_ids => [],
                                      :product_prices => [:price, :supplier_price, :supplier_id],
                                      product_parts_attributes: [:_destroy, :id, :part_id, :quantity],
                                      product_images_attributes: [:created_at, :_destroy, :id, :filename, :display_order]
                                    )
    end
end
