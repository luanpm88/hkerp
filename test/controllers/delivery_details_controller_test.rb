require 'test_helper'

class DeliveryDetailsControllerTest < ActionController::TestCase
  setup do
    @delivery_detail = delivery_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:delivery_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create delivery_detail" do
    assert_difference('DeliveryDetail.count') do
      post :create, delivery_detail: { delivery_id: @delivery_detail.delivery_id, order_detail_id: @delivery_detail.order_detail_id, quantity: @delivery_detail.quantity }
    end

    assert_redirected_to delivery_detail_path(assigns(:delivery_detail))
  end

  test "should show delivery_detail" do
    get :show, id: @delivery_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @delivery_detail
    assert_response :success
  end

  test "should update delivery_detail" do
    patch :update, id: @delivery_detail, delivery_detail: { delivery_id: @delivery_detail.delivery_id, order_detail_id: @delivery_detail.order_detail_id, quantity: @delivery_detail.quantity }
    assert_redirected_to delivery_detail_path(assigns(:delivery_detail))
  end

  test "should destroy delivery_detail" do
    assert_difference('DeliveryDetail.count', -1) do
      delete :destroy, id: @delivery_detail
    end

    assert_redirected_to delivery_details_path
  end
end
