class ProductsController < ApplicationController
  load_and_authorize_resource :except => [:ajax_new, :ajax_show, :ajax_create, :datatable]
  
  before_action :set_product, only: [:product_log, :ajax_product_prices, :trash, :do_combine_parts, :combine_parts, :do_update_price, :update_price, :show, :edit, :update, :destroy, :ajax_show]

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
      
      
      actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      
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
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
    
    @products = Product.statistics(@from_date, @to_date)
    
    if params[:pdf] == "1"
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
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:intro, :note, :serial_numbers, :stock, :name, :description, :price, :product_code, :manufacturer_id, :unit, :warranty,
                                      :category_ids => [],
                                      :product_prices => [:price, :supplier_price, :supplier_id],
                                      product_parts_attributes: [:_destroy, :id, :part_id, :quantity],
                                      product_images_attributes: [:created_at, :_destroy, :id, :filename, :display_order]
                                    )
    end
end
