require 'test_helper'

class CustomerPosControllerTest < ActionController::TestCase
  setup do
    @customer_po = customer_pos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:customer_pos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create customer_po" do
    assert_difference('CustomerPo.count') do
      post :create, customer_po: { code: @customer_po.code, filename: @customer_po.filename }
    end

    assert_redirected_to customer_po_path(assigns(:customer_po))
  end

  test "should show customer_po" do
    get :show, id: @customer_po
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @customer_po
    assert_response :success
  end

  test "should update customer_po" do
    patch :update, id: @customer_po, customer_po: { code: @customer_po.code, filename: @customer_po.filename }
    assert_redirected_to customer_po_path(assigns(:customer_po))
  end

  test "should destroy customer_po" do
    assert_difference('CustomerPo.count', -1) do
      delete :destroy, id: @customer_po
    end

    assert_redirected_to customer_pos_path
  end
end
