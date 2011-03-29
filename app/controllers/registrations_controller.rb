class RegistrationsController < ApplicationController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  include Devise::Controllers::InternalHelpers

  # GET /resource/sign_up
  def new
    build_resource({})
    render_with_scope :new
  end

  def auth_callback
		auth = request.env["omniauth.auth"]  
		redirect_to root_path if auth.blank?

		@auth = Authorization.find_from_hash(auth)
		if current_user
      current_user.authorizations.create(:provider => auth['provider'], :uid => auth['uid']) #Add an auth to existing
      flash[:notice] = "成功绑定了 #{auth['provider']} 帐号。"
			redirect_to edit_user_registration_path
		elsif @auth
      UserSession.create(@auth.user, true) #User is present. Login the user with his social account
			flash[:notice] = "登陆成功。"
			redirect_to "/"
		else
      if Setting.allow_register
        @new_auth = Authorization.create_from_hash(auth, current_user) #Create a new user
        UserSession.create(@new_auth.user, true) #Log the authorizing user in.
        flash[:notice] = "欢迎来自 #{auth['provider']} 的用户，你的帐号已经创建成功。"
        redirect_to "/"
      else
        flash[:alert] = "你还没有注册用户。"
      end
		end
  end

  # POST /resource
  def create
    if not Setting.allow_register
      render_404
      return false
    end

    build_resource    

    if resource.save
      if resource.active?
        set_flash_message :notice, :signed_up
        sign_in_and_redirect(resource_name, resource)
      else
        set_flash_message :notice, :inactive_signed_up, :reason => resource.inactive_message.to_s
        expire_session_data_after_sign_in!
        redirect_to after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end
  end

  # GET /resource/edit
  def edit
    render_with_scope :edit
  end

  # PUT /resource
  def update
    if resource.update_attributes(params[resource_name])
      set_flash_message :notice, :updated
      sign_in resource_name, resource, :bypass => true
      redirect_to edit_user_registration_path
    else
      #clean_up_passwords(resource)
      render_with_scope :edit
    end
  end

  # DELETE /resource
  def destroy
    resource.destroy
    sign_out_and_redirect(self.resource)
    set_flash_message :notice, :destroyed
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    expire_session_data_after_sign_in!
    redirect_to new_registration_path(resource_name)
  end

  protected

    # Build a devise resource passing in the session. Useful to move
    # temporary session data to the newly created user.
    def build_resource(hash=nil)
      hash ||= params[resource_name] || {}
      self.resource = resource_class.new_with_session(hash, session)
    end

    # The path used after sign up. You need to overwrite this method
    # in your own RegistrationsController.
    def after_sign_up_path_for(resource)
      after_sign_in_path_for(resource)
    end

    # Overwrite redirect_for_sign_in so it takes uses after_sign_up_path_for.
    def redirect_location(scope, resource) #:nodoc:
      stored_location_for(scope) || after_sign_up_path_for(resource)
    end

    # The path used after sign up for inactive accounts. You need to overwrite
    # this method in your own RegistrationsController.
    def after_inactive_sign_up_path_for(resource)
      root_path
    end

    # The default url to be used after updating a resource. You need to overwrite
    # this method in your own RegistrationsController.
    def after_update_path_for(resource)
      if defined?(super)
        ActiveSupport::Deprecation.warn "Defining after_update_path_for in ApplicationController " <<
          "is deprecated. Please add a RegistrationsController to your application and define it there."
        super
      else
        after_sign_in_path_for(resource)
      end
    end

    # Authenticates the current scope and gets a copy of the current resource.
    # We need to use a copy because we don't want actions like update changing
    # the current user in place.
    def authenticate_scope!
      send(:"authenticate_#{resource_name}!", true)
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    end
end
