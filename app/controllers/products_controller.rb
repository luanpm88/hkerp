class ProductsController < ApplicationController
  load_and_authorize_resource :except => [:ajax_new, :ajax_show, :ajax_create, :datatable]
  
  before_action :set_product, only: [:product_activity_history, :ajax_product_prices, :trash, :do_combine_parts, :combine_parts, :do_update_price, :update_price, :show, :edit, :update, :destroy, :ajax_show]

  # GET /products
  # GET /products.json
  def index
    @products = Product.order("name").all
    respond_to do |format|
      format.html
      format.json {
        render json: Product.full_text_search(params[:q])
      }
    end
  end
  
  def datatable
    authorize! :read, Product
    
    result = Product.datatable(params)
   
    result[:items].each_with_index do |item, index|
      
      
      actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      
      if can? :update, item
        actions += '<li>'+view_context.link_to("Edit", edit_product_path(item))+'</li>'
      end
      if can? :create, ProductStockUpdate
        actions += '<li>'+view_context.link_to("Update Stock (Nhập Kho)", new_product_stock_update_path(product_id: item.id))+'</li>'
      end
      if can? :ajax_product_prices, item
        actions += '<li>'+item.price_history_link(false)+'</li>'
      end
      if can? :update_price, item
        actions += '<li>'+view_context.link_to("Update Price", {controller: "products", action: "update_price", id: item.id})+'</li>'
      end
      if can? :trash, item
        actions += '<li>'+view_context.link_to('<i class="icon-trash"></i> Trash'.html_safe, {controller: "products", action: "trash", id: item.id}, method: :patch)+'</li>'
      end
      if can? :un_trash, item
        actions += '<li>'+view_context.link_to('<i class="icon-trash"></i> Un-Trash'.html_safe, {controller: "products", action: "un_trash", id: item.id}, method: :patch)+'</li>'
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
  end

  # GET /products/1/edit
  def edit
    (1..(10-@product.product_parts.count)).each do |i|
      @product.product_parts.build
    end
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)
    @product.user = current_user

    respond_to do |format|
      if @product.save
        @product.update_price(params["product_prices"])
        format.html { redirect_to products_url, notice: 'Product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        @product.update_price(params["product_prices"])
        format.html { redirect_to products_url, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
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
                 order_supplier_history: @product.order_supplier_history]
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
        @product.update_price(params["product_prices"])
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
    
  end
  
  def do_update_price
    respond_to do |format|
      if @product.update_price(params["product_prices"])       
        format.html { redirect_to products_url, notice: 'Product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def trash
    respond_to do |format|
      if @product.trash       
        format.html { redirect_to products_url, notice: 'Product was successfully trashed.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { redirect_to products_url, alert: 'Product was unsuccessfully trashed.' }
        format.json { render action: 'show', status: :created, location: @product }
      end
    end
  end
  
  def un_trash
    respond_to do |format|
      if @product.un_trash       
        format.html { redirect_to products_url, notice: 'Product was successfully trashed.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { redirect_to products_url, alert: 'Product was unsuccessfully trashed.' }
        format.json { render action: 'show', status: :created, location: @product }
      end
    end
  end
  
  def statistics
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
    
    @year = @order.order_date.year
    
    @products = Product.statistics(@year, @month_val)
  end
  
  
  def ajax_product_prices
    render layout: nil
  end
  
  def product_activity_history
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
    
    @year = @order.order_date.year
    
    @history = @product.product_activity_history(@year, @month_val)
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:serial_numbers, :stock, :name, :description, :price, :product_code, :manufacturer_id, :unit, :warranty,
                                      :category_ids => [],
                                      :product_prices => [:price, :supplier_price, :supplier_id],
                                      product_parts_attributes: [:_destroy, :id, :part_id, :quantity]
                                    )
    end
end
