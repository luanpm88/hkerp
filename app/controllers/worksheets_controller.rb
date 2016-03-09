class WorksheetsController < ApplicationController
  include WorksheetsHelper
  load_and_authorize_resource
  before_action :set_worksheet, only: [:show, :edit, :update, :destroy, :trash, :un_trash]

  # GET /worksheets
  # GET /worksheets.json
  def index
    @worksheets = Worksheet.all
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
  end

  # GET /worksheets/1
  # GET /worksheets/1.json
  def show
  end

  # GET /worksheets/new
  def new
    @worksheet = Worksheet.new
    9.times do
      @worksheet.worksheet_intineraries.build
    end
  end

  # GET /worksheets/1/edit
  def edit
    (9-@worksheet.worksheet_intineraries.count).times do
      @worksheet.worksheet_intineraries.build
    end
  end

  # POST /worksheets
  # POST /worksheets.json
  def create
    @worksheet = Worksheet.new(worksheet_params)
    @worksheet.creator_id = current_user.id

    respond_to do |format|
      if @worksheet.save
        format.html { redirect_to worksheets_path(tab_page: 1), notice: 'Worksheet was successfully created.' }
        format.json { render action: 'show', status: :created, location: @worksheet }
      else
        format.html { render action: 'new' }
        format.json { render json: @worksheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /worksheets/1
  # PATCH/PUT /worksheets/1.json
  def update
    respond_to do |format|
      if @worksheet.update(worksheet_params)
        format.html { redirect_to worksheets_path(tab_page: 1), notice: 'Worksheet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @worksheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /worksheets/1
  # DELETE /worksheets/1.json
  def destroy
    @worksheet.destroy
    respond_to do |format|
      format.html { redirect_to worksheets_path(tab_page: 1) }
      format.json { head :no_content }
    end
  end
  
  #DATABASE
  def datatable
    result = Worksheet.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_worksheet_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def trash
    respond_to do |format|
      if @worksheet.trash       
        format.html { redirect_to params[:tab_page].present? ? worksheets_url(tab_page: 1) : worksheets_url, notice: 'Worksheet was successfully trashed.' }
        format.json { render action: 'show', status: :created, location: @worksheet }
      else
        format.html { redirect_to params[:tab_page].present? ? worksheets_url(tab_page: 1) : worksheets_url, alert: 'Worksheet was unsuccessfully trashed.' }
        format.json { render action: 'show', status: :created, location: @worksheet }
      end
    end
  end
  
  def un_trash
    respond_to do |format|
      if @worksheet.un_trash       
        format.html { redirect_to params[:tab_page].present? ? worksheets_url(tab_page: 1) : worksheets_url, notice: 'Worksheet was successfully trashed.' }
        format.json { render action: 'show', status: :created, location: @worksheet }
      else
        format.html { redirect_to params[:tab_page].present? ? worksheets_url(tab_page: 1) : worksheets_url, alert: 'Worksheet was unsuccessfully trashed.' }
        format.json { render action: 'show', status: :created, location: @worksheet }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_worksheet
      @worksheet = Worksheet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def worksheet_params
      params.require(:worksheet).permit(:creator_id, :user_ids => [], worksheet_intineraries_attributes: [:id, :start_address, :end_address, :start_at, :end_at, :distance, :description, :_destroy])
    end
end
