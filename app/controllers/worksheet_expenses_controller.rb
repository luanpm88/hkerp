class WorksheetExpensesController < ApplicationController
  before_action :set_worksheet_expense, only: [:show, :edit, :update, :destroy, :delete, :undo_deleted]
  include WorksheetExpensesHelper

  # GET /worksheet_expenses
  # GET /worksheet_expenses.json
  def index
    @worksheet_expenses = WorksheetExpense.all
    
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: WorksheetExpense.full_text_search(params[:q])
      }
    end
  end
  
  def datatable
    result = WorksheetExpense.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_worksheet_expense_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end

  # GET /worksheet_expenses/1
  # GET /worksheet_expenses/1.json
  def show
  end

  # GET /worksheet_expenses/new
  def new
    @worksheet_expense = WorksheetExpense.new
  end

  # GET /worksheet_expenses/1/edit
  def edit
  end

  # POST /worksheet_expenses
  # POST /worksheet_expenses.json
  def create
    @worksheet_expense = WorksheetExpense.new(worksheet_expense_params)
    @worksheet_expense.creator = current_user
    @worksheet_expense.status = "active"

    respond_to do |format|
      if @worksheet_expense.save
        format.html { redirect_to "/home/close_tab", notice: 'Worksheet expense was successfully created.' }
        format.json { render action: 'show', status: :created, location: @worksheet_expense }
      else
        format.html { render action: 'new' }
        format.json { render json: @worksheet_expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /worksheet_expenses/1
  # PATCH/PUT /worksheet_expenses/1.json
  def update
    respond_to do |format|
      if @worksheet_expense.update(worksheet_expense_params)
        format.html { redirect_to "/home/close_tab", notice: 'Worksheet expense was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @worksheet_expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /worksheet_expenses/1
  # DELETE /worksheet_expenses/1.json
  def destroy
    @worksheet_expense.destroy
    respond_to do |format|
      format.html { redirect_to worksheet_expenses_url }
      format.json { head :no_content }
    end
  end
  
  def delete
    @worksheet_expense = WorksheetExpense.find(params[:id])
    @worksheet_expense.status = "deleted"
    @worksheet_expense.save
    respond_to do |format|
      format.html { redirect_to "/home/close_tab" }
      format.json { head :no_content }
    end
  end
  
  def undo_deleted
    @worksheet_expense = WorksheetExpense.find(params[:id])
    @worksheet_expense.status = "active"
    @worksheet_expense.save
    respond_to do |format|
      format.html { redirect_to "/home/close_tab" }
      format.json { head :no_content }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_worksheet_expense
      @worksheet_expense = WorksheetExpense.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def worksheet_expense_params
      params.require(:worksheet_expense).permit(:name, :price, :type_name, :description, :creator_id)
    end
end
