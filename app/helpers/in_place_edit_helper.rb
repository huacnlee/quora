# coding: utf-8
# Hacking for on_the_spot helper
module InPlaceEditHelper
  def in_place_edit_tag(object, field, options={})
    options.reverse_merge!(:label => "修改",:text_id => nil, :type => :input)
    update_url = "/update_in_place"
    html_options = { :id => "#{object.class.name.underscore}__#{field}__#{object.id}",
                     :class => 'in_place_edit',
                     :'data-type' => options[:type],
                     :'data-text-id' => options[:text_id],
                     :onclick => "return App.inPlaceEdit(this);",
                     :'data-url' => update_url}

    content_tag("a", html_options) do
      options[:label]
    end
  end
end
