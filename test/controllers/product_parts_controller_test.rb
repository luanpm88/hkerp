require 'test_helper'

class ProductPartsControllerTest < ActionController::TestCase
  setup do
    @product_part = product_parts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:product_parts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product_part" do
    assert_difference('ProductPart.count') do
      post :create, product_part: { part_id: @product_part.part_id, product_id: @product_part.product_id, quantity: @product_part.quantity }
    end

    assert_redirected_to product_part_path(assigns(:product_part))
  end

  test "should show product_part" do
    get :show, id: @product_part
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product_part
    assert_response :success
  end

  test "should update product_part" do
    patch :update, id: @product_part, product_part: { part_id: @product_part.part_id, product_id: @product_part.product_id, quantity: @product_part.quantity }
    assert_redirected_to product_part_path(assigns(:product_part))
  end

  test "should destroy product_part" do
    assert_difference('ProductPart.count', -1) do
      delete :destroy, id: @product_part
    end

    assert_redirected_to product_parts_path
  end
end
