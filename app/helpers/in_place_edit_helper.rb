# coding: utf-8
# Hacking for on_the_spot helper
module InPlaceEditHelper
  def in_place_edit_tag(object, field, options={})
    return "" if not current_user
    options.reverse_merge!(:label => "修改",
                           :text_id => nil,
                           :rich => true, 
                           :type => :input,
                           :height => nil,
                           :width => nil)
    update_url = "/update_in_place"
    html_options = { :id => "#{object.class.name.underscore}__#{field}__#{object.id}",
                     :class => 'in_place_edit',
                     :'data-type' => options[:type],
                     :'data-text-id' => options[:text_id],
                     :'data-rich' => options[:rich],
                     :onclick => "return App.inPlaceEdit(this, {'is_mobile_device': #{is_mobile_device? ? 'true' : 'false'}});",
                     :'data-url' => update_url}
    if !options[:width].blank?
      html_options[:"data-width"] = options[:width]
    end
    if !options[:height].blank?
      html_options[:"data-height"] = options[:height]
    end

    content_tag("a", html_options) do
      options[:label]
    end
  end
end
