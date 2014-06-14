require 'test_helper'

class SupplierOrderDetailsControllerTest < ActionController::TestCase
  setup do
    @supplier_order_detail = supplier_order_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:supplier_order_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create supplier_order_detail" do
    assert_difference('SupplierOrderDetail.count') do
      post :create, supplier_order_detail: { price: @supplier_order_detail.price, product_id: @supplier_order_detail.product_id, product_name: @supplier_order_detail.product_name, quantity: @supplier_order_detail.quantity, supplier_order_id: @supplier_order_detail.supplier_order_id }
    end

    assert_redirected_to supplier_order_detail_path(assigns(:supplier_order_detail))
  end

  test "should show supplier_order_detail" do
    get :show, id: @supplier_order_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @supplier_order_detail
    assert_response :success
  end

  test "should update supplier_order_detail" do
    patch :update, id: @supplier_order_detail, supplier_order_detail: { price: @supplier_order_detail.price, product_id: @supplier_order_detail.product_id, product_name: @supplier_order_detail.product_name, quantity: @supplier_order_detail.quantity, supplier_order_id: @supplier_order_detail.supplier_order_id }
    assert_redirected_to supplier_order_detail_path(assigns(:supplier_order_detail))
  end

  test "should destroy supplier_order_detail" do
    assert_difference('SupplierOrderDetail.count', -1) do
      delete :destroy, id: @supplier_order_detail
    end

    assert_redirected_to supplier_order_details_path
  end
end
