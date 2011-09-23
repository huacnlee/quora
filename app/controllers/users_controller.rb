# coding: utf-8
class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:auth_callback]
  before_filter :init_user, :except => [:auth_callback, :login, :logout]

  def init_user
    @user = User.find_by_slug(params[:id])
    if @user.blank? or !@user.deleted.blank?
      render_404
    end
    @ask_to_user = Ask.new
  end

  def answered
    @per_page = 10
    @asks = Ask.normal.recent.find(@user.answered_ask_ids)
                  .paginate(:page => params[:page], :per_page => @per_page)
    set_seo_meta("#{@user.name}回答过的问题")
    if params[:format] == "js"
      render "/users/answered_asks.js"
    end
  end
  
  def asked_to
    @per_page = 10
    @asks = Ask.normal.recent.asked_to(@user.id)
                  .paginate(:page => params[:page], :per_page => @per_page)
    set_seo_meta("问#{@user.name}的问题")
    if params[:format] == "js"
      render "/asks/index.js"
    else
      render "asked"
    end
  end

  def show
    @per_page = 10
    @logs = Log.desc("$natural").where(:user_id => @user.id).paginate(:page => params[:page], :per_page => @per_page)
    set_seo_meta(@user.name)
    
    if params[:format] == "js"
      render "/logs/index.js"
    end
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
    @per_page = 20
    @topics = @user.followed_topics.desc("$natural")
                  .paginate(:page => params[:page], :per_page => @per_page)
    
    set_seo_meta("#{@user.name}关注的话题")
    if params[:format] == "js"
      render "following_topics.js"
    end
  end
  
  def followers
    @per_page = 20
    @followers = @user.followers.desc("$natural")
                  .paginate(:page => params[:page], :per_page => @per_page)
    
    set_seo_meta("关注#{@user.name}的人")
    if params[:format] == "js"
      render "followers.js"
    end
  end
  
  def following
    @per_page = 20
    @followers = @user.following.desc("$natural")
                  .paginate(:page => params[:page], :per_page => @per_page)
    
    set_seo_meta("#{@user.name}关注的人")
    if params[:format] == "js"
      render "followers.js"
    else
      render "followers"
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
  
  def login
    if !cookies[:TBSSO].blank?
      redirect_to "/auth/taobao/callback"
    else
      redirect_to "https://backyard.seraph.taobao.com/login/?url=http://#{Setting.domain}/auth/taobao/callback"
    end
  end
  
  def logout
    sign_out current_user
    redirect_to "https://backyard.seraph.taobao.com/login/?action=logout&url=#{root_url}"
  end

  def auth_callback
    if params[:provider] == "taobao"
      auto_taobao_sso
      return
    end
    
		auth = request.env["omniauth.auth"]  
		redirect_to root_path if auth.blank?
    provider_name = auth['provider'].gsub(/^t/,"").titleize
    Rails.logger.debug { auth }

		if current_user
      Authorization.create_from_hash(auth, current_user)
      flash[:notice] = "成功绑定了 #{provider_name} 帐号。"
			redirect_to edit_user_registration_path
		elsif @user = Authorization.find_from_hash(auth)
      sign_in @user
			flash[:notice] = "登陆成功。"
			redirect_to "/"
		else
      if Setting.allow_register
        @new_user = Authorization.create_from_hash(auth, current_user) #Create a new user
        if @new_user.errors.blank?
          sign_in @new_user
          flash[:notice] = "欢迎来自 #{provider_name} 的用户，你的帐号已经创建成功。"
          redirect_to "/"
        else
          flash[:notice] = "#{provider_name}的帐号提供信息不全，无法直接登陆，请先注册。"
          redirect_to "/register"
        end
      else
        flash[:alert] = "你还没有注册用户。"
        redirect_back_or_default "/login"
      end
		end
  end
  
  def auto_taobao_sso
    hash = {}
    cookies[:TBSSO].split("&").map { |row| hash[row.split("=")[0]] = row.split("=")[1] }
    auth  = { "uid" => hash["sign"], 
               "provider" => "taobao_sso",
               "user_info" => {
                 "name" => CGI::unescape(hash["cname"]).split("(").first,
                 "email" => hash["email"],
                 'slug' => hash['userid']
               }
             }
    if @user = Authorization.find_from_hash(auth)
      sign_in @user
			flash[:notice] = "登陆成功。"
			redirect_to "/"
    else
      @new_user = Authorization.create_from_hash(auth, current_user) #Create a new user
      if @new_user.errors.blank?
        sign_in @new_user
        flash[:notice] = "欢迎来自淘宝的用户，你的帐号已经创建成功。"
        redirect_to "/"
      else
        render :text => @new_user.errors
        flash[:notice] = "淘宝的帐号提供信息不全，无法直接登陆，请先注册。"

      end
    end
  end

end
