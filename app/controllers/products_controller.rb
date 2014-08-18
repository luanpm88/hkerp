class ProductsController < ApplicationController
  load_and_authorize_resource :except => [:ajax_new, :ajax_show, :ajax_create, :datatable]
  
  before_action :set_product, only: [:show, :edit, :update, :destroy, :ajax_show]

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
    
    
    case params["order"]["0"]["column"]
    when "1"
      order = "categories.name"
    when "2"
      order = "manufacturers.name"
    when "3"
      order = "products.name"
    when "4"
      order = "products.price"
    else
      order = "products.name"
    end
    
    order += " "+params["order"]["0"]["dir"]
    
    where = ["true"]
    where = "LOWER(products.name) LIKE '%#{params["search"]["value"].downcase}%'" if !params["search"]["value"].empty?

    @products = Product.joins(:categories).joins(:manufacturer).select("DISTINCT manufacturers.name AS manufacturer_name, categories.name AS category_name, products.name, products.price").where(where).order(order).limit(params[:length]).offset(params["start"])
    data = []
    @products.each do |product|
      item = ['<div class="checkbox check-default"><input id="checkbox#{product.id}" type="checkbox" value="1"><label for="checkbox#{product.id}"></label></div>',
              product.category_name,
              product.manufacturer_name,
              product.name,
              product.formated_price,
              ''
            ]
      data << item
    end 
    
    total = Product.where(where).count
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    puts result
    
    puts params
    render json: result
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)
    @product.user = current_user

    respond_to do |format|
      if @product.save
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
    p params[:product][:category_ids]
    
    respond_to do |format|
      if @product.update(product_params)
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
    
    @data = Hash[display_name: @product.display_name,product: @product, order_supplier_history: @product.order_supplier_history]
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
        format.html { render action: 'ajax_show', :layout => nil, :id => @product.id }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'ajax_new', :layout => nil }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :description, :price, :product_code, :manufacturer_id, :unit, :warranty, :category_ids => [])
    end
end
