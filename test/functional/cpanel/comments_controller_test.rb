require 'test_helper'

class Cpanel::CommentsControllerTest < ActionController::TestCase
  setup do
    @cpanel_comment = cpanel_comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cpanel_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cpanel_comment" do
    assert_difference('Cpanel::Comment.count') do
      post :create, :cpanel_comment => @cpanel_comment.attributes
    end

    assert_redirected_to cpanel_comment_path(assigns(:cpanel_comment))
  end

  test "should show cpanel_comment" do
    get :show, :id => @cpanel_comment.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cpanel_comment.to_param
    assert_response :success
  end

  test "should update cpanel_comment" do
    put :update, :id => @cpanel_comment.to_param, :cpanel_comment => @cpanel_comment.attributes
    assert_redirected_to cpanel_comment_path(assigns(:cpanel_comment))
  end

  test "should destroy cpanel_comment" do
    assert_difference('Cpanel::Comment.count', -1) do
      delete :destroy, :id => @cpanel_comment.to_param
    end

    assert_redirected_to cpanel_comments_path
  end
end
