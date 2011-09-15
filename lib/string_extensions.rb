module StringExtensions
  JS_ESCAPE_MAP = {
                    '\\'    => '\\\\',
                    '</'    => '<\/',
                    "\r\n"  => '\n',
                    "\n"    => '\n',
                    "\r"    => '\n',
                    '"'     => '\\"',
                    "'"     => "\\'" }
  
  # clear unsafe char with url slug
  def safe_slug(spliter = '-',allow_number = true)
    slug = self
    regex = /[^a-zA-Z\-0-9]/
    if not allow_number
      regex = /[^a-zA-Z\-]/
    end
    slug = slug.gsub(regex,spliter).downcase  
    slug = slug.gsub(/^\-+|\-+$/,'').gsub(/\-+/,spliter)
    slug
  end
  
  def escape_javascript
    if self
      self.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }
    else
      ''
    end
  end

  def md5
    Digest::SHA1.hexdigest(self)
  end
end

String.send :include,StringExtensions
