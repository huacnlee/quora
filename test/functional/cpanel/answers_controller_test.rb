require 'test_helper'

class Cpanel::AnswersControllerTest < ActionController::TestCase
  setup do
    @cpanel_answer = cpanel_answers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cpanel_answers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cpanel_answer" do
    assert_difference('Cpanel::Answer.count') do
      post :create, :cpanel_answer => @cpanel_answer.attributes
    end

    assert_redirected_to cpanel_answer_path(assigns(:cpanel_answer))
  end

  test "should show cpanel_answer" do
    get :show, :id => @cpanel_answer.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cpanel_answer.to_param
    assert_response :success
  end

  test "should update cpanel_answer" do
    put :update, :id => @cpanel_answer.to_param, :cpanel_answer => @cpanel_answer.attributes
    assert_redirected_to cpanel_answer_path(assigns(:cpanel_answer))
  end

  test "should destroy cpanel_answer" do
    assert_difference('Cpanel::Answer.count', -1) do
      delete :destroy, :id => @cpanel_answer.to_param
    end

    assert_redirected_to cpanel_answers_path
  end
end
