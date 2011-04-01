require 'test_helper'

class Cpanel::TopicsControllerTest < ActionController::TestCase
  setup do
    @cpanel_topic = cpanel_topics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cpanel_topics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cpanel_topic" do
    assert_difference('Cpanel::Topic.count') do
      post :create, :cpanel_topic => @cpanel_topic.attributes
    end

    assert_redirected_to cpanel_topic_path(assigns(:cpanel_topic))
  end

  test "should show cpanel_topic" do
    get :show, :id => @cpanel_topic.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cpanel_topic.to_param
    assert_response :success
  end

  test "should update cpanel_topic" do
    put :update, :id => @cpanel_topic.to_param, :cpanel_topic => @cpanel_topic.attributes
    assert_redirected_to cpanel_topic_path(assigns(:cpanel_topic))
  end

  test "should destroy cpanel_topic" do
    assert_difference('Cpanel::Topic.count', -1) do
      delete :destroy, :id => @cpanel_topic.to_param
    end

    assert_redirected_to cpanel_topics_path
  end
end
