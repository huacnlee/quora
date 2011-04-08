# coding: utf-8
class UserMailer < BaseMailer
  def welcome(user_id)
    @user = User.find(user_id)
    @title = "欢迎加入#{Setting.app_name}"
    mail(:to => @user.email,:subject => @title, :from => Setting.email_sender)
  end

  # 被关注
  def be_followed(user_id, follower_id)
    @user = User.find(user_id)
    @follower = User.find(follower_id)
    @title = "#{@follower.name}在#{Setting.app_name}关注了你"
    mail(:to => @user.email,
         :subject => @title, :from => Setting.email_sender)
  end

  def self.new_answer_to_followers(answer_id)
    Thread.new {
      @answer = Answer.find(answer_id)
      @ask = Ask.find(@answer.ask_id)
      emails = @ask.followers.excludes(:id => @answer.user_id).collect { |u| u.email }
      emails.each do |email|
        UserMailer.new_answer(answer_id,email).deliver
      end
    }
  end

  # 问题有了新回答
  def new_answer(answer_id,email)
    @answer = Answer.find(answer_id)
    @ask = Ask.find(@answer.ask_id)
    @title = "问题“#{@ask.title}”有了新的回答"
    mail(:to => email, :subject => @title, :from => Setting.email_sender)
  end


end
