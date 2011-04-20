# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  before_filter :init, :load_notice
  has_mobile_fu

  def init
    if params[:force_format] == "mobile"
      cookies[:mobile] = true
    elsif params[:force_format] == "desktop"
      cookies[:mobile] = nil
    end

    if !cookies[:mobile].blank? and request.format.to_sym == :html
      force_mobile_format
    end
  end

  def load_notice
    @notice = Notice.last
    if !@notice.blank? and !@notice.end_at.blank?
      if @notice.end_at < Time.now
        @notice = nil
      end
    end
  end
  
  # 暂时不使用mobile-fu的功能，仅仅使用其is_mobile_device?方法
  #include ActionController::MobileFu::InstanceMethods
  #helper_method :is_mobile_device?
  
  # Comet Server
  use_zomet

  # set page title, meta keywords, meta description
  def set_seo_meta(title, options = {})
    keywords = options[:keywords] || ""
    description = options[:description] || ""

    if title.length > 0
      @page_title = "#{title} &raquo; "
    end
    @meta_keywords = keywords
    @meta_description = description
  end

  def render_404
    render_optional_error_file(404)
  end

  def render_optional_error_file(status_code)
    status = status_code.to_s
    if ["404", "422", "500"].include?(status)
      render :template => "/errors/#{status}.html.erb", :status => status, :layout => "application"
    else
      render :template => "/errors/unknown.html.erb", :status => status, :layout => "application"
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def require_user(options = {})
    format = options[:format] || :html
    format = format.to_s
    if format == "html"
      authenticate_user!
    elsif format == "json"
      if current_user.blank?
        render :json => { :success => false, :msg => "你还没有登陆。" }
        return false
      end
    elsif format == "text"
      # Ajax 调用的时候如果没有登陆，那直接返回 nologin，前段自动处理
      if current_user.blank?
        render :text => "_nologin_" 
        return false
      end
    elsif format == "js"
      if current_user.blank?
        render :text => "location.href = '/login';"
        return false
      end
    end
    true
  end

  def require_user_json
    require_user(:format => :json)
  end

  def require_user_js
    require_user(:format => :js)
  end

  def require_user_text
    require_user(:format => :text)
  end
  
  def tag_options(options, escape = true)
    unless options.blank?
      attrs = []
      options.each_pair do |key, value|
        if BOOLEAN_ATTRIBUTES.include?(key)
          attrs << %(#{key}="#{key}") if value
        elsif !value.nil?
          final_value = value.is_a?(Array) ? value.join(" ") : value
          final_value = html_escape(final_value) if escape
          attrs << %(#{key}="#{final_value}")
        end
      end
      " #{attrs.sort * ' '}".html_safe unless attrs.empty?
    end
  end
  
  def tag(name, options = nil, open = false, escape = true)
    "<#{name}#{tag_options(options, escape) if options}#{open ? ">" : " />"}".html_safe
  end
  
  def simple_format(text, html_options={}, options={})
    text = ''.html_safe if text.nil?
    start_tag = tag('p', html_options, true)
    text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
    text.gsub!(/\n\n+/, "</p><br />#{start_tag}")  # 2+ newline  -> paragraph
    text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
    text.insert 0, start_tag
    text.html_safe.safe_concat("</p>")
  end
  
end
