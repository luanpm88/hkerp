class CustomerPosController < ApplicationController
  include ApplicationHelper
  
  load_and_authorize_resource
  
  before_action :set_customer_po, only: [:file, :show, :edit, :update, :destroy]

  # GET /customer_pos
  # GET /customer_pos.json
  def index
    #@customer_pos = CustomerPo.all    
    respond_to do |format|
      format.html
      format.json {
        render json: CustomerPo.full_text_search(params[:q])
      }
    end
  end

  # GET /customer_pos/1
  # GET /customer_pos/1.json
  def show
  end

  # GET /customer_pos/new
  def new
    @customer_po = CustomerPo.new
  end

  # GET /customer_pos/1/edit
  def edit
  end

  # POST /customer_pos
  # POST /customer_pos.json
  def create
    @customer_po = CustomerPo.new(customer_po_params)
    
    @customer_po.user = current_user

    respond_to do |format|
      if @customer_po.save
        format.html { redirect_to customer_pos_path, notice: 'Customer po was successfully created.' }
        format.json { render action: 'show', status: :created, location: @customer_po }
      else
        format.html { render action: 'new' }
        format.json { render json: @customer_po.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customer_pos/1
  # PATCH/PUT /customer_pos/1.json
  def update
    respond_to do |format|
      if @customer_po.update(customer_po_params)
        format.html { redirect_to @customer_po, notice: 'Customer po was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @customer_po.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customer_pos/1
  # DELETE /customer_pos/1.json
  def destroy
    @customer_po.destroy
    respond_to do |format|
      format.html { redirect_to customer_pos_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    authorize! :view_list, Order
    
    result = CustomerPo.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_customer_po_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def file
    send_file @customer_po.file_path(params[:type]), :disposition => 'inline'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer_po
      @customer_po = CustomerPo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_po_params
      params.require(:customer_po).permit(:code, :filename)
    end
end
