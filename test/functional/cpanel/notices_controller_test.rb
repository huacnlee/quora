require 'test_helper'

class Cpanel::NoticesControllerTest < ActionController::TestCase
  setup do
    @cpanel_notice = cpanel_notices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cpanel_notices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cpanel_notice" do
    assert_difference('Cpanel::Notice.count') do
      post :create, :cpanel_notice => @cpanel_notice.attributes
    end

    assert_redirected_to cpanel_notice_path(assigns(:cpanel_notice))
  end

  test "should show cpanel_notice" do
    get :show, :id => @cpanel_notice.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cpanel_notice.to_param
    assert_response :success
  end

  test "should update cpanel_notice" do
    put :update, :id => @cpanel_notice.to_param, :cpanel_notice => @cpanel_notice.attributes
    assert_redirected_to cpanel_notice_path(assigns(:cpanel_notice))
  end

  test "should destroy cpanel_notice" do
    assert_difference('Cpanel::Notice.count', -1) do
      delete :destroy, :id => @cpanel_notice.to_param
    end

    assert_redirected_to cpanel_notices_path
  end
end
