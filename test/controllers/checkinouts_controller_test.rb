require 'test_helper'

class CheckinoutsControllerTest < ActionController::TestCase
  setup do
    @checkinout = checkinouts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:checkinouts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create checkinout" do
    assert_difference('Checkinout.count') do
      post :create, checkinout: { check_time: @checkinout.check_time, user_id: @checkinout.user_id }
    end

    assert_redirected_to checkinout_path(assigns(:checkinout))
  end

  test "should show checkinout" do
    get :show, id: @checkinout
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @checkinout
    assert_response :success
  end

  test "should update checkinout" do
    patch :update, id: @checkinout, checkinout: { check_time: @checkinout.check_time, user_id: @checkinout.user_id }
    assert_redirected_to checkinout_path(assigns(:checkinout))
  end

  test "should destroy checkinout" do
    assert_difference('Checkinout.count', -1) do
      delete :destroy, id: @checkinout
    end

    assert_redirected_to checkinouts_path
  end
end
