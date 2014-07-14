class SupplierOrderDetailsController < ApplicationController
  before_action :set_supplier_order_detail, only: [:show, :edit, :update, :destroy, :ajax_edit, :ajax_update, :ajax_destroy]

  # GET /supplier_order_details
  # GET /supplier_order_details.json
  def index
    @supplier_order_details = SupplierOrderDetail.all
  end

  # GET /supplier_order_details/1
  # GET /supplier_order_details/1.json
  def show
  end

  # GET /supplier_order_details/new
  def new
    @supplier_order_detail = SupplierOrderDetail.new
  end

  # GET /supplier_order_details/1/edit
  def edit
  end

  # POST /supplier_order_details
  # POST /supplier_order_details.json
  def create
    @supplier_order_detail = SupplierOrderDetail.new(supplier_order_detail_params)

    respond_to do |format|
      if @supplier_order_detail.save
        format.html { redirect_to @supplier_order_detail, notice: 'Supplier order detail was successfully created.' }
        format.json { render action: 'show', status: :created, location: @supplier_order_detail }
      else
        format.html { render action: 'new' }
        format.json { render json: @supplier_order_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /supplier_order_details/1
  # PATCH/PUT /supplier_order_details/1.json
  def update
    respond_to do |format|
      if @supplier_order_detail.update(supplier_order_detail_params)
        format.html { redirect_to @supplier_order_detail, notice: 'Supplier order detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @supplier_order_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /supplier_order_details/1
  # DELETE /supplier_order_details/1.json
  def destroy
    @supplier_order_detail.destroy
    respond_to do |format|
      format.html { redirect_to supplier_order_details_url }
      format.json { head :no_content }
    end
  end
  
  # GET /suuplier_order_details/new
  def ajax_new
    @supplier_order_detail = SupplierOrderDetail.new
    
    if (!params[:supplier_order_id].nil?)
      # @order_detail.order = Order.find_by_id(params[:order_id])
    end
    
    render :layout => nil
  end
  
  # GET /order_details/1/edit
  def ajax_edit
    render :layout => nil
  end
  
  def ajax_create
    @supplier_order_detail = SupplierOrderDetail.new(supplier_order_detail_params)

    respond_to do |format|
      if @supplier_order_detail.save
        format.html { render action: 'ajax_show', :layout => nil, :id => @supplier_order_detail.id }
        format.json { render action: 'show', status: :created, location: @supplier_order_detail }
      else
        format.html { render action: 'ajax_new', :layout => nil }
        format.json { render json: @supplier_order_detail.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def ajax_update
    respond_to do |format|
      if @supplier_order_detail.update(supplier_order_detail_params)
        format.html { render action: 'ajax_show', :layout => nil, :id => @supplier_order_detail.id }
        format.json { head :no_content }
      else
        format.html { render action: 'ajax_edit', :layout => nil, :id => @supplier_order_detail.id }
        format.json { render json: @supplier_order_detail.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /contacts/1
  def ajax_destroy
    @supplier_order_detail.destroy
    
    render :nothing => true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier_order_detail
      @supplier_order_detail = SupplierOrderDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplier_order_detail_params
      params.require(:supplier_order_detail).permit(:supplier_order_id, :product_id, :quantity, :price, :product_name, :product_description, :unit, :warranty)
    end
end
