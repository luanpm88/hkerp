require 'test_helper'

class CustomerPosOrdersControllerTest < ActionController::TestCase
  setup do
    @customer_pos_order = customer_pos_orders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:customer_pos_orders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create customer_pos_order" do
    assert_difference('CustomerPosOrder.count') do
      post :create, customer_pos_order: { customer_po_id: @customer_pos_order.customer_po_id, order_id: @customer_pos_order.order_id }
    end

    assert_redirected_to customer_pos_order_path(assigns(:customer_pos_order))
  end

  test "should show customer_pos_order" do
    get :show, id: @customer_pos_order
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @customer_pos_order
    assert_response :success
  end

  test "should update customer_pos_order" do
    patch :update, id: @customer_pos_order, customer_pos_order: { customer_po_id: @customer_pos_order.customer_po_id, order_id: @customer_pos_order.order_id }
    assert_redirected_to customer_pos_order_path(assigns(:customer_pos_order))
  end

  test "should destroy customer_pos_order" do
    assert_difference('CustomerPosOrder.count', -1) do
      delete :destroy, id: @customer_pos_order
    end

    assert_redirected_to customer_pos_orders_path
  end
end
