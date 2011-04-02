module ApplicationHelper
  def admin?(user)
    return true if Setting.admin_emails.index(user.email)
    return false
  end
  
  def owner?(item)
    return false if current_user.blank?
    user_id = nil
    if item.class == current_user.class
      user_id = item.id
    else
      user_id = item.user_id
    end
    if user_id == current_user.id
      return true
    end
    return false
  end

  def auto_link_urls(text, href_options = {}, options = {})
    extra_options = tag_options(href_options.stringify_keys) || ""
    limit = options[:limit] || nil
    text.gsub(AUTO_LINK_RE) do
      all, a, b, c = $&, $1, $2, $3
      if a =~ /<a\s/i # don't replace URL's that are already linked
        all
      else
        text = b + c
        text = yield(text) if block_given?
        if(not limit.blank?)
          text = truncate(text, :length => limit)
        end
        %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}"#{extra_options}>#{text}</a>)
      end
    end
  end

    AUTO_LINK_RE = %r{
                        (                          # leading text
                          <\w+.*?>|                # leading HTML tag, or
                          [^=!:'"/]|               # leading punctuation, or 
                          ^                        # beginning of line
                        )
                        (
                          (?:https?://)|           # protocol spec, or
                          (?:www\.)                # www.*
                        ) 
                        (
                          [-0-9A-Za-z_]+           # subdomain or domain
                          (?:\.[-0-9A-Za-z_]+)*    # remaining subdomains or domain
                          (?::\d+)?                # port
                          (?:/(?:(?:[~0-9A-Za-z_\+%-]|(?:[,.;:][^\s$]))+)?)* # path
                          (?:\?[0-9A-Za-z_\+%&=.;-]+)?     # query string
                          (?:\#[0-9A-Za-z_\-]*)?   # trailing anchor
                        )
  }x unless const_defined?(:AUTO_LINK_RE)

  # form auth token
  def auth_token
    raw "<input name=\"authenticity_token\" type=\"hidden\" value=\"#{form_authenticity_token}\" />"
  end
  
  # 去除区域里面的内容的换行标记  
  def spaceless(&block)
    data = with_output_buffer(&block)
    data = data.gsub(/\n\s+/," ")
    data = data.gsub(/>\s+</,"> <")
    data
  end
  
end
