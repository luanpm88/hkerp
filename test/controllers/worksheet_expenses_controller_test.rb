require 'test_helper'

class WorksheetExpensesControllerTest < ActionController::TestCase
  setup do
    @worksheet_expense = worksheet_expenses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:worksheet_expenses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create worksheet_expense" do
    assert_difference('WorksheetExpense.count') do
      post :create, worksheet_expense: { creator_id: @worksheet_expense.creator_id, description: @worksheet_expense.description, name: @worksheet_expense.name, price: @worksheet_expense.price, type_name: @worksheet_expense.type_name }
    end

    assert_redirected_to worksheet_expense_path(assigns(:worksheet_expense))
  end

  test "should show worksheet_expense" do
    get :show, id: @worksheet_expense
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @worksheet_expense
    assert_response :success
  end

  test "should update worksheet_expense" do
    patch :update, id: @worksheet_expense, worksheet_expense: { creator_id: @worksheet_expense.creator_id, description: @worksheet_expense.description, name: @worksheet_expense.name, price: @worksheet_expense.price, type_name: @worksheet_expense.type_name }
    assert_redirected_to worksheet_expense_path(assigns(:worksheet_expense))
  end

  test "should destroy worksheet_expense" do
    assert_difference('WorksheetExpense.count', -1) do
      delete :destroy, id: @worksheet_expense
    end

    assert_redirected_to worksheet_expenses_path
  end
end
