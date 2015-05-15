class CommissionProgramsController < ApplicationController
  before_action :set_commission_program, only: [:start, :stop, :show, :edit, :update, :destroy]

  # GET /commission_programs
  # GET /commission_programs.json
  def index
    @commission_programs = CommissionProgram.all_commission_programs
  end

  # GET /commission_programs/1
  # GET /commission_programs/1.json
  def show
  end

  # GET /commission_programs/new
  def new
    @commission_program = CommissionProgram.new
  end

  # GET /commission_programs/1/edit
  def edit
  end

  # POST /commission_programs
  # POST /commission_programs.json
  def create
    @commission_program = CommissionProgram.new(commission_program_params)
    @commission_program.user = current_user
    
    respond_to do |format|
      if @commission_program.save
        format.html { redirect_to commission_programs_path, notice: 'Commission program was successfully created.' }
        format.json { render action: 'show', status: :created, location: @commission_program }
      else
        format.html { render action: 'new' }
        format.json { render json: @commission_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /commission_programs/1
  # PATCH/PUT /commission_programs/1.json
  def update
    respond_to do |format|
      if @commission_program.update(commission_program_params)
        format.html { redirect_to commission_programs_path, notice: 'Commission program was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @commission_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /commission_programs/1
  # DELETE /commission_programs/1.json
  def destroy
    @commission_program.destroy
    respond_to do |format|
      format.html { redirect_to commission_programs_url }
      format.json { head :no_content }
    end
  end
  
  def start
    respond_to do |format|
      if @commission_program.start
        format.html { redirect_to commission_programs_path, notice: 'Commission program was successfully started.' }
        format.json { render action: 'show', status: :created, location: @commission_program }
      else
        format.html { redirect_to commission_programs_path, alert: 'Commission program was unsuccessfully started.' }
        format.json { render json: @commission_program.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def stop
    respond_to do |format|
      if @commission_program.stop
        format.html { redirect_to commission_programs_path, notice: 'Commission program was successfully stopped.' }
        format.json { render action: 'show', status: :created, location: @commission_program }
      else
        format.html { redirect_to commission_programs_path, alert: 'Commission program was unsuccessfully stopped.' }
        format.json { render json: @commission_program.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commission_program
      @commission_program = CommissionProgram.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def commission_program_params
      params.require(:commission_program).permit(
                                                  :commission_rate,
                                                  :name,
                                                  :interval_type,
                                                  :min_amount,
                                                  :max_amount,
                                                  :published_at,
                                                  :unpublished_at,
                                                  :description
                                                )
    end
end
