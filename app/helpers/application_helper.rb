# coding: utf-8
module ApplicationHelper
  def use_yahei_font?(ua)
    use = true
    ["Windows NT 5.2", "Windows NT 5.1"].each do |w|
      if ua.include?(w)
        use = false
        break
      end
    end
    return use
  end
  
  def ask_notification_tag(ask_id, log, a, show_ask = true)
    return if ask_id.nil?
    tag = ""
    ask = Ask.find(ask_id)
    return "" if ask.nil? or log.user.nil?
    # ask_tag = "<a href=\"#{ask_path(ask)}\">#{ask.title}</a>"
    user_tag = "<a href=\"/users/#{log.user.slug}\">#{log.user.name}</a> "
    
    case a
    when "AGREE_ANSWER", "NEW_ANSWER_COMMENT"
      tag += user_tag + " #{a == "AGREE_ANSWER" ? "赞成" : "评论"}了你在"
      ask_tag = "<a href=\"#{ask_path(ask)}#{a == "AGREE_ANSWER" ? "#answer_" + log.target_id.to_s : "?eawc=yes&awid=" + log.title.to_s + "#answer_" + log.title.to_s}\">#{show_ask ? ask.title : "该问题中的回答。"}</a>" + (show_ask ? " 中的回答。" : "")
      tag += (show_ask ? "问题 " : "") + ask_tag
    when "NEW_ANSWER", "NEW_ASK_COMMENT"
      tag += user_tag + " #{a == "NEW_ANSWER" ? "回答" : "评论"}了"
      ask_tag = "<a href=\"#{ask_path(ask)}#{a == "NEW_ASK_COMMENT" ? "?easc=yes&asid=" + log.target_parent_id.to_s : ""}#answer_#{log.target_id.to_s}\">#{show_ask ? ask.title : "该问题。"}</a>"
      tag += (show_ask ? "问题 " : "") + ask_tag
    when "THANK_ANSWER"
      tag += user_tag + "感谢了你"
      if show_ask
        ask_tag = "在 <a href=\"#{ask_path(ask)}?nr=1#answer_#{log.target_id.to_s}\">#{ask.title}</a> 的回答。"
      else
        ask_tag = "的回答。"
      end
      tag += ask_tag
    when "INVITE_TO_ANSWER"
      tag += user_tag + "邀请你回答 "
      if show_ask
        tag += "<a href=\"#{ask_path(ask)}?nr=1\">#{ask.title}</a>"
      end
    when "ASK_USER"
      tag += user_tag + "向你询问 "
      if show_ask
        tag += "<a href=\"#{ask_path(ask)}?nr=1\">#{ask.title}</a>"
      end
    end
    return tag
  end
  
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
