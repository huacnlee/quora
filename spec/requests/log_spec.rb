# coding: utf-8
require 'spec_helper'

describe "logs_controller requests" do
  it "when user follow/unfollow asks, display it via index" do
    user = FactoryGirl.create(:user)
    ask = FactoryGirl.create(:ask)
    Log.all.delete
    visit logs_path
    page.should_not have_content('关注了该问题')
    page.should_not have_content('取消关注了该问题')
    user.follow_ask(ask)
    visit logs_path
    page.should have_content('关注了该问题')
    user.unfollow_ask(ask)
    visit logs_path
    user.unfollow_ask(ask)
    page.should have_content('取消关注了该问题')
  end
end
