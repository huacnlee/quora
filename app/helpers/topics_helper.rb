module TopicsHelper
  def topic_name_tag(topic, options = {})
    limit = options[:limit] || 10
    prefix = options[:prefix] || ''
    raw "<a href='#{topic_path(topic.name)}' title='#{h(topic.name)}'>#{prefix}#{h(topic.name)}</a>"
  end

  def topic_cover_tag(topic, size, options = {})
    limit = options[:limit] || 10
      url = eval("topic.cover.#{size}.url")
    raw "<a href='#{topic_path(topic.name)}' title='#{h(topic.name)}'>#{image_tag(url, :class => size)}</a>"
  end
end
