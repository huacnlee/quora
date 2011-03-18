# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  # set page title, meta keywords, meta description
  def set_seo_meta(options = {})
    title = options[:title] || ""
    keywords = options[:keywords] || ""
    description = options[:description] || ""

    if title.length > 0
      @page_title = "#{title} &raquo; "
    end
    @meta_keywords = keywords
    @meta_description = description
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def require_user
    authenticate_user!
  end
  
end
