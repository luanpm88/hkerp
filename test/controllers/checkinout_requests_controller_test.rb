require 'test_helper'

class CheckinoutRequestsControllerTest < ActionController::TestCase
  setup do
    @checkinout_request = checkinout_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:checkinout_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create checkinout_request" do
    assert_difference('CheckinoutRequest.count') do
      post :create, checkinout_request: { check_time: @checkinout_request.check_time, content: @checkinout_request.content, status: @checkinout_request.status, user_id: @checkinout_request.user_id }
    end

    assert_redirected_to checkinout_request_path(assigns(:checkinout_request))
  end

  test "should show checkinout_request" do
    get :show, id: @checkinout_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @checkinout_request
    assert_response :success
  end

  test "should update checkinout_request" do
    patch :update, id: @checkinout_request, checkinout_request: { check_time: @checkinout_request.check_time, content: @checkinout_request.content, status: @checkinout_request.status, user_id: @checkinout_request.user_id }
    assert_redirected_to checkinout_request_path(assigns(:checkinout_request))
  end

  test "should destroy checkinout_request" do
    assert_difference('CheckinoutRequest.count', -1) do
      delete :destroy, id: @checkinout_request
    end

    assert_redirected_to checkinout_requests_path
  end
end
