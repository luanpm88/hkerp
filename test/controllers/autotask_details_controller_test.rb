require 'test_helper'

class AutotaskDetailsControllerTest < ActionController::TestCase
  setup do
    @autotask_detail = autotask_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:autotask_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create autotask_detail" do
    assert_difference('AutotaskDetail.count') do
      post :create, autotask_detail: { autotask_id: @autotask_detail.autotask_id, item_count: @autotask_detail.item_count }
    end

    assert_redirected_to autotask_detail_path(assigns(:autotask_detail))
  end

  test "should show autotask_detail" do
    get :show, id: @autotask_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @autotask_detail
    assert_response :success
  end

  test "should update autotask_detail" do
    patch :update, id: @autotask_detail, autotask_detail: { autotask_id: @autotask_detail.autotask_id, item_count: @autotask_detail.item_count }
    assert_redirected_to autotask_detail_path(assigns(:autotask_detail))
  end

  test "should destroy autotask_detail" do
    assert_difference('AutotaskDetail.count', -1) do
      delete :destroy, id: @autotask_detail
    end

    assert_redirected_to autotask_details_path
  end
end
