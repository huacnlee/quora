# coding: utf-8
class UsersController < ApplicationController
  def show
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
