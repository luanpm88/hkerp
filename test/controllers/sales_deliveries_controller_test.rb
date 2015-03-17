require 'test_helper'

class SalesDeliveriesControllerTest < ActionController::TestCase
  setup do
    @sales_delivery = sales_deliveries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sales_deliveries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sales_delivery" do
    assert_difference('SalesDelivery.count') do
      post :create, sales_delivery: { order_id: @sales_delivery.order_id }
    end

    assert_redirected_to sales_delivery_path(assigns(:sales_delivery))
  end

  test "should show sales_delivery" do
    get :show, id: @sales_delivery
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sales_delivery
    assert_response :success
  end

  test "should update sales_delivery" do
    patch :update, id: @sales_delivery, sales_delivery: { order_id: @sales_delivery.order_id }
    assert_redirected_to sales_delivery_path(assigns(:sales_delivery))
  end

  test "should destroy sales_delivery" do
    assert_difference('SalesDelivery.count', -1) do
      delete :destroy, id: @sales_delivery
    end

    assert_redirected_to sales_deliveries_path
  end
end
