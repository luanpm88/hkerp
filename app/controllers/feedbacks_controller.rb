class FeedbacksController < ApplicationController
  include FeedbacksHelper
  load_and_authorize_resource
  before_action :set_feedback, only: [:check, :picture, :show, :edit, :update, :destroy]

  # GET /feedbacks
  # GET /feedbacks.json
  def index
    @feedbacks = Feedback.all
  end

  # GET /feedbacks/1
  # GET /feedbacks/1.json
  def show
  end

  # GET /feedbacks/new
  def new
    @feedback = Feedback.new
  end

  # GET /feedbacks/1/edit
  def edit
  end

  # POST /feedbacks
  # POST /feedbacks.json
  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.user = current_user

    respond_to do |format|
      if @feedback.save
        format.html { redirect_to feedbacks_path(tab_page: 1), notice: 'Feedback was successfully created.' }
        format.json { render action: 'show', status: :created, location: @feedback }
      else
        format.html { render action: 'new', tab_page: 1 }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /feedbacks/1
  # PATCH/PUT /feedbacks/1.json
  def update
    respond_to do |format|
      if @feedback.update(feedback_params)
        format.html { redirect_to feedbacks_path(tab_page: 1), notice: 'Feedback was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: 1 }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.json
  def destroy
    @feedback.destroy
    respond_to do |format|
      format.html { redirect_to feedbacks_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = Feedback.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_feedback_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def picture
    send_file @feedback.picture_path(params[:type]), :disposition => 'inline'
  end
  
  def check
    value = params[:value] == "true" ? 1 : nil
    @feedback.update_attribute(:status, value)
    
    render layout: nil
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feedback
      @feedback = Feedback.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def feedback_params
      params.require(:feedback).permit(:user_id, :title, :content, :image, :status)
    end
end
