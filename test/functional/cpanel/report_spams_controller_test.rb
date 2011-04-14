require 'test_helper'

class Cpanel::ReportSpamsControllerTest < ActionController::TestCase
  setup do
    @cpanel_report_spam = cpanel_report_spams(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cpanel_report_spams)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cpanel_report_spam" do
    assert_difference('Cpanel::ReportSpam.count') do
      post :create, :cpanel_report_spam => @cpanel_report_spam.attributes
    end

    assert_redirected_to cpanel_report_spam_path(assigns(:cpanel_report_spam))
  end

  test "should show cpanel_report_spam" do
    get :show, :id => @cpanel_report_spam.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cpanel_report_spam.to_param
    assert_response :success
  end

  test "should update cpanel_report_spam" do
    put :update, :id => @cpanel_report_spam.to_param, :cpanel_report_spam => @cpanel_report_spam.attributes
    assert_redirected_to cpanel_report_spam_path(assigns(:cpanel_report_spam))
  end

  test "should destroy cpanel_report_spam" do
    assert_difference('Cpanel::ReportSpam.count', -1) do
      delete :destroy, :id => @cpanel_report_spam.to_param
    end

    assert_redirected_to cpanel_report_spams_path
  end
end
