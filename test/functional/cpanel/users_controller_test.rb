require 'test_helper'

class Cpanel::UsersControllerTest < ActionController::TestCase
  setup do
    @cpanel_user = cpanel_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cpanel_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cpanel_user" do
    assert_difference('Cpanel::User.count') do
      post :create, :cpanel_user => @cpanel_user.attributes
    end

    assert_redirected_to cpanel_user_path(assigns(:cpanel_user))
  end

  test "should show cpanel_user" do
    get :show, :id => @cpanel_user.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cpanel_user.to_param
    assert_response :success
  end

  test "should update cpanel_user" do
    put :update, :id => @cpanel_user.to_param, :cpanel_user => @cpanel_user.attributes
    assert_redirected_to cpanel_user_path(assigns(:cpanel_user))
  end

  test "should destroy cpanel_user" do
    assert_difference('Cpanel::User.count', -1) do
      delete :destroy, :id => @cpanel_user.to_param
    end

    assert_redirected_to cpanel_users_path
  end
end
