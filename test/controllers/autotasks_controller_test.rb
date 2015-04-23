require 'test_helper'

class AutotasksControllerTest < ActionController::TestCase
  setup do
    @autotask = autotasks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:autotasks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create autotask" do
    assert_difference('Autotask.count') do
      post :create, autotask: { item_count: @autotask.item_count, name: @autotask.name, time_interval: @autotask.time_interval }
    end

    assert_redirected_to autotask_path(assigns(:autotask))
  end

  test "should show autotask" do
    get :show, id: @autotask
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @autotask
    assert_response :success
  end

  test "should update autotask" do
    patch :update, id: @autotask, autotask: { item_count: @autotask.item_count, name: @autotask.name, time_interval: @autotask.time_interval }
    assert_redirected_to autotask_path(assigns(:autotask))
  end

  test "should destroy autotask" do
    assert_difference('Autotask.count', -1) do
      delete :destroy, id: @autotask
    end

    assert_redirected_to autotasks_path
  end
end
