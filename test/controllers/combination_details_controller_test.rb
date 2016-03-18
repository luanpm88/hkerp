require 'test_helper'

class CombinationDetailsControllerTest < ActionController::TestCase
  setup do
    @combination_detail = combination_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:combination_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create combination_detail" do
    assert_difference('CombinationDetail.count') do
      post :create, combination_detail: { combination_id: @combination_detail.combination_id, product_id: @combination_detail.product_id, quantity: @combination_detail.quantity, stock_after: @combination_detail.stock_after, stock_before: @combination_detail.stock_before }
    end

    assert_redirected_to combination_detail_path(assigns(:combination_detail))
  end

  test "should show combination_detail" do
    get :show, id: @combination_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @combination_detail
    assert_response :success
  end

  test "should update combination_detail" do
    patch :update, id: @combination_detail, combination_detail: { combination_id: @combination_detail.combination_id, product_id: @combination_detail.product_id, quantity: @combination_detail.quantity, stock_after: @combination_detail.stock_after, stock_before: @combination_detail.stock_before }
    assert_redirected_to combination_detail_path(assigns(:combination_detail))
  end

  test "should destroy combination_detail" do
    assert_difference('CombinationDetail.count', -1) do
      delete :destroy, id: @combination_detail
    end

    assert_redirected_to combination_details_path
  end
end
