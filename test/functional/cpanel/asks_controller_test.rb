require 'test_helper'

class Cpanel::AsksControllerTest < ActionController::TestCase
  setup do
    @cpanel_ask = cpanel_asks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cpanel_asks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cpanel_ask" do
    assert_difference('Cpanel::Ask.count') do
      post :create, :cpanel_ask => @cpanel_ask.attributes
    end

    assert_redirected_to cpanel_ask_path(assigns(:cpanel_ask))
  end

  test "should show cpanel_ask" do
    get :show, :id => @cpanel_ask.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cpanel_ask.to_param
    assert_response :success
  end

  test "should update cpanel_ask" do
    put :update, :id => @cpanel_ask.to_param, :cpanel_ask => @cpanel_ask.attributes
    assert_redirected_to cpanel_ask_path(assigns(:cpanel_ask))
  end

  test "should destroy cpanel_ask" do
    assert_difference('Cpanel::Ask.count', -1) do
      delete :destroy, :id => @cpanel_ask.to_param
    end

    assert_redirected_to cpanel_asks_path
  end
end
