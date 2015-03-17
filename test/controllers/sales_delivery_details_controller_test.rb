require 'test_helper'

class SalesDeliveryDetailsControllerTest < ActionController::TestCase
  setup do
    @sales_delivery_detail = sales_delivery_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sales_delivery_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sales_delivery_detail" do
    assert_difference('SalesDeliveryDetail.count') do
      post :create, sales_delivery_detail: { order_detail_id: @sales_delivery_detail.order_detail_id, quantity: @sales_delivery_detail.quantity, sales_delivery_id: @sales_delivery_detail.sales_delivery_id }
    end

    assert_redirected_to sales_delivery_detail_path(assigns(:sales_delivery_detail))
  end

  test "should show sales_delivery_detail" do
    get :show, id: @sales_delivery_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sales_delivery_detail
    assert_response :success
  end

  test "should update sales_delivery_detail" do
    patch :update, id: @sales_delivery_detail, sales_delivery_detail: { order_detail_id: @sales_delivery_detail.order_detail_id, quantity: @sales_delivery_detail.quantity, sales_delivery_id: @sales_delivery_detail.sales_delivery_id }
    assert_redirected_to sales_delivery_detail_path(assigns(:sales_delivery_detail))
  end

  test "should destroy sales_delivery_detail" do
    assert_difference('SalesDeliveryDetail.count', -1) do
      delete :destroy, id: @sales_delivery_detail
    end

    assert_redirected_to sales_delivery_details_path
  end
end
