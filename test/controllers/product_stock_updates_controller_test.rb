require 'test_helper'

class ProductStockUpdatesControllerTest < ActionController::TestCase
  setup do
    @product_stock_update = product_stock_updates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:product_stock_updates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product_stock_update" do
    assert_difference('ProductStockUpdate.count') do
      post :create, product_stock_update: { product_id: @product_stock_update.product_id, quantity: @product_stock_update.quantity, serial_numbers: @product_stock_update.serial_numbers }
    end

    assert_redirected_to product_stock_update_path(assigns(:product_stock_update))
  end

  test "should show product_stock_update" do
    get :show, id: @product_stock_update
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product_stock_update
    assert_response :success
  end

  test "should update product_stock_update" do
    patch :update, id: @product_stock_update, product_stock_update: { product_id: @product_stock_update.product_id, quantity: @product_stock_update.quantity, serial_numbers: @product_stock_update.serial_numbers }
    assert_redirected_to product_stock_update_path(assigns(:product_stock_update))
  end

  test "should destroy product_stock_update" do
    assert_difference('ProductStockUpdate.count', -1) do
      delete :destroy, id: @product_stock_update
    end

    assert_redirected_to product_stock_updates_path
  end
end
