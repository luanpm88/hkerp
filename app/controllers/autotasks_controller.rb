class AutotasksController < ApplicationController
  before_action :set_autotask, only: [:show, :edit, :update, :destroy]

  # GET /autotasks
  # GET /autotasks.json
  def index
    @autotasks = Autotask.all
  end

  # GET /autotasks/1
  # GET /autotasks/1.json
  def show
  end

  # GET /autotasks/new
  def new
    @autotask = Autotask.new
  end

  # GET /autotasks/1/edit
  def edit
  end

  # POST /autotasks
  # POST /autotasks.json
  def create
    @autotask = Autotask.new(autotask_params)

    respond_to do |format|
      if @autotask.save
        format.html { redirect_to @autotask, notice: 'Autotask was successfully created.' }
        format.json { render action: 'show', status: :created, location: @autotask }
      else
        format.html { render action: 'new' }
        format.json { render json: @autotask.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /autotasks/1
  # PATCH/PUT /autotasks/1.json
  def update
    respond_to do |format|
      if @autotask.update(autotask_params)
        format.html { redirect_to @autotask, notice: 'Autotask was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @autotask.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /autotasks/1
  # DELETE /autotasks/1.json
  def destroy
    @autotask.destroy
    respond_to do |format|
      format.html { redirect_to autotasks_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_autotask
      @autotask = Autotask.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def autotask_params
      params.require(:autotask).permit(:name, :item_count, :time_interval)
    end
end
