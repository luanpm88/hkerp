require 'test_helper'

class CommissionProgramsControllerTest < ActionController::TestCase
  setup do
    @commission_program = commission_programs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:commission_programs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create commission_program" do
    assert_difference('CommissionProgram.count') do
      post :create, commission_program: { max_amount: @commission_program.max_amount, min_amount: @commission_program.min_amount, pushlished_at: @commission_program.pushlished_at, time_interval: @commission_program.time_interval }
    end

    assert_redirected_to commission_program_path(assigns(:commission_program))
  end

  test "should show commission_program" do
    get :show, id: @commission_program
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @commission_program
    assert_response :success
  end

  test "should update commission_program" do
    patch :update, id: @commission_program, commission_program: { max_amount: @commission_program.max_amount, min_amount: @commission_program.min_amount, pushlished_at: @commission_program.pushlished_at, time_interval: @commission_program.time_interval }
    assert_redirected_to commission_program_path(assigns(:commission_program))
  end

  test "should destroy commission_program" do
    assert_difference('CommissionProgram.count', -1) do
      delete :destroy, id: @commission_program
    end

    assert_redirected_to commission_programs_path
  end
end
