# coding: utf-8
class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:auth_callback]
  before_filter :init_user

  def init_user
    @user = User.find_by_slug(params[:id])
    if @user.blank?
      render_404
    end
  end

  def answered
    @per_page = 10
    @asks = Ask.normal.recent.find(@user.answered_ask_ids)
                  .paginate(:page => params[:page], :per_page => @per_page)
    set_seo_meta("#{@user.name}回答过的问题")
    if params[:format] == "js"
      render "/asks/index.js"
    end
  end

  def show
    @per_page = 10
    @logs = Log.desc("$natural").where(:user_id => @user.id).paginate(:page => params[:page], :per_page => @per_page)
    set_seo_meta(@user.name)
  end

  def asked
    @per_page = 10
    @asks = @user.asks.normal.recent
                  .paginate(:page => params[:page], :per_page => @per_page)
    set_seo_meta("#{@user.name}问过的问题")
    if params[:format] == "js"
      render "/asks/index.js"
    end
  end
  
  def following_topics
    @per_page = 10
    @topics = @user.followed_topics.desc("$natural")
                  .paginate(:page => params[:page], :per_page => @per_page)
    
    set_seo_meta("#{@user.name}关注的话题")
    if params[:format] == "js"
      render "following_topics.js"
    end
  end
  
  def follow
    if not @user
      render :text => "0"
      return
    end
    current_user.follow(@user)
    render :text => "1"
  end
  
  def unfollow
    if not @user
      render :text => "0"
      return
    end
    current_user.unfollow(@user)
    render :text => "1"
  end

  def auth_callback
		auth = request.env["omniauth.auth"]  
		redirect_to root_path if auth.blank?

		if current_user
      Authorization.create_from_hash(auth, current_user)
      flash[:notice] = "成功绑定了 #{auth['provider']} 帐号。"
			redirect_to edit_user_registration_path
		elsif @user = Authorization.find_from_hash(auth)
      sign_in @user
			flash[:notice] = "登陆成功。"
			redirect_to "/"
		else
      if Setting.allow_register
        @new_user = Authorization.create_from_hash(auth, current_user) #Create a new user
        sign_in @new_user
        flash[:notice] = "欢迎来自 #{auth['provider']} 的用户，你的帐号已经创建成功。"
        redirect_to "/"
      else
        flash[:alert] = "你还没有注册用户。"
        redirect_back_or_default "/login"
      end
		end
  end

end
