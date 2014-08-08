class SupplierOrdersController < ApplicationController
  load_and_authorize_resource
  
  before_action :set_supplier_order, only: [:show, :edit, :update, :destroy, :download_pdf]

  # GET /supplier_orders
  # GET /supplier_orders.json
  def index
    @supplier_orders = SupplierOrder.all
  end

  # GET /supplier_orders/1
  # GET /supplier_orders/1.json
  def show
    @hk = Contact.HK
    render :layout => nil
  end

  # GET /supplier_orders/new
  def new
    @supplier_order = SupplierOrder.new
  end

  # GET /supplier_orders/1/edit
  def edit
  end

  # POST /supplier_orders
  # POST /supplier_orders.json
  def create
    @supplier_order = SupplierOrder.new(supplier_order_params)
    @supplier_order.salesperson = current_user

    respond_to do |format|
      if @supplier_order.save
        format.html { redirect_to supplier_orders_path, notice: 'Supplier order was successfully created.' }
        format.json { render action: 'show', status: :created, location: @supplier_order }
      else
        format.html { render action: 'new' }
        format.json { render json: @supplier_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /supplier_orders/1
  # PATCH/PUT /supplier_orders/1.json
  def update
    respond_to do |format|
      if @supplier_order.update(supplier_order_params)
        format.html { redirect_to supplier_orders_path, notice: 'Supplier order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @supplier_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /supplier_orders/1
  # DELETE /supplier_orders/1.json
  def destroy
    @supplier_order.destroy
    respond_to do |format|
      format.html { redirect_to supplier_orders_url }
      format.json { head :no_content }
    end
  end
  
  def download_pdf
    @hk = Contact.HK
    render  :pdf => "purchase_order_"+@supplier_order.id.to_s,
            :template => 'supplier_orders/show.html.erb',
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier_order
      @supplier_order = SupplierOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplier_order_params
      params.require(:supplier_order).permit(:supplier_id, :tax_id, :supplier_order_detail_ids => [])
    end
end
