require 'test_helper'

class CityTypesControllerTest < ActionController::TestCase
  setup do
    @city_type = city_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:city_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create city_type" do
    assert_difference('CityType.count') do
      post :create, city_type: { name: @city_type.name }
    end

    assert_redirected_to city_type_path(assigns(:city_type))
  end

  test "should show city_type" do
    get :show, id: @city_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @city_type
    assert_response :success
  end

  test "should update city_type" do
    patch :update, id: @city_type, city_type: { name: @city_type.name }
    assert_redirected_to city_type_path(assigns(:city_type))
  end

  test "should destroy city_type" do
    assert_difference('CityType.count', -1) do
      delete :destroy, id: @city_type
    end

    assert_redirected_to city_types_path
  end
end
