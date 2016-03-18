class AutotaskDetailsController < ApplicationController
  before_action :set_autotask_detail, only: [:show, :edit, :update, :destroy]

  # GET /autotask_details
  # GET /autotask_details.json
  def index
    @autotask_details = AutotaskDetail.all
  end

  # GET /autotask_details/1
  # GET /autotask_details/1.json
  def show
  end

  # GET /autotask_details/new
  def new
    @autotask_detail = AutotaskDetail.new
  end

  # GET /autotask_details/1/edit
  def edit
  end

  # POST /autotask_details
  # POST /autotask_details.json
  def create
    @autotask_detail = AutotaskDetail.new(autotask_detail_params)

    respond_to do |format|
      if @autotask_detail.save
        format.html { redirect_to @autotask_detail, notice: 'Autotask detail was successfully created.' }
        format.json { render action: 'show', status: :created, location: @autotask_detail }
      else
        format.html { render action: 'new' }
        format.json { render json: @autotask_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /autotask_details/1
  # PATCH/PUT /autotask_details/1.json
  def update
    respond_to do |format|
      if @autotask_detail.update(autotask_detail_params)
        format.html { redirect_to @autotask_detail, notice: 'Autotask detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @autotask_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /autotask_details/1
  # DELETE /autotask_details/1.json
  def destroy
    @autotask_detail.destroy
    respond_to do |format|
      format.html { redirect_to autotask_details_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_autotask_detail
      @autotask_detail = AutotaskDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def autotask_detail_params
      params.require(:autotask_detail).permit(:autotask_id, :item_count, :time_interval)
    end
end
