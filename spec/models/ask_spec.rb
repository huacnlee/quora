# coding: utf-8
require 'spec_helper'

describe "Ask" do
  before(:all) do
    @user1 = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user)
  end
  it "when create and invite, notify the invitee" do
    @ask = FactoryGirl.create(:ask)
    Notification.all.delete
    @user1.notifications.unread.count.should eq 0
    invite = AskInvite.invite(@ask.id, @user1.id, @user2.id)
    @user1.reload
    @user1.notifications.unread.count.should eq 1
  end
  it "when create with to_user_id, notify the to_user" do
    Notification.all.delete
    @user1.notifications.unread.count.should eq 0
    @ask = FactoryGirl.create(:ask,:to_user_id => @user1.id)
    @user1.reload
    @user1.notifications.unread.count.should eq 1
  end
end
