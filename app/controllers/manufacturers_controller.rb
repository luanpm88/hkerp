class ManufacturersController < ApplicationController
  load_and_authorize_resource
  
  before_action :set_manufacturer, only: [:show, :edit, :update, :destroy]

  # GET /manufacturers
  # GET /manufacturers.json
  def index
    @manufacturers = Manufacturer.all
    respond_to do |format|
      format.html  {render layout: "content" if params[:tab_page].present?}
      format.json {
        render json: Manufacturer.full_text_search(params[:q])
      }
    end
  end

  # GET /manufacturers/1
  # GET /manufacturers/1.json
  def show
  end

  # GET /manufacturers/new
  def new
    @manufacturer = Manufacturer.new
    render layout: "content" if params[:tab_page].present?
  end

  # GET /manufacturers/1/edit
  def edit
    render layout: "content" if params[:tab_page].present?
  end

  # POST /manufacturers
  # POST /manufacturers.json
  def create
    @manufacturer = Manufacturer.new(manufacturer_params)
    @manufacturer.user_id = current_user.id

    respond_to do |format|
      if @manufacturer.save
        format.html { redirect_to params[:tab_page].present? ? {action: "edit", id: @manufacturer.id, tab_page: 1} : manufacturers_url, notice: 'Manufacturer was successfully created.' }
        format.json { render action: 'show', status: :created, location: @manufacturer }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @manufacturer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /manufacturers/1
  # PATCH/PUT /manufacturers/1.json
  def update
    respond_to do |format|
      if @manufacturer.update(manufacturer_params)
        format.html { redirect_to params[:tab_page].present? ? {action: "edit", id: @manufacturer.id, tab_page: 1} : manufacturers_url, notice: 'Manufacturer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @manufacturer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manufacturers/1
  # DELETE /manufacturers/1.json
  def destroy
    @manufacturer.destroy
    respond_to do |format|
      format.html { redirect_to manufacturers_url(tab_page: params[:tab_page]) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_manufacturer
      @manufacturer = Manufacturer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def manufacturer_params
      params.require(:manufacturer).permit(:name, :description)
    end
end
