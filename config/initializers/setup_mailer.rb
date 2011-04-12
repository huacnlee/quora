#ActionMailer::Base.smtp_settings = {
  #:address => "smtp.gmail.com",
  #:enable_starttls_auto => true,
  #:port => 587,
  #:domain => Setting.domain,
  #:authentication => :login,
  #:user_name => Setting.smtp_username,
  #:password => Setting.smtp_password
#}
ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  :access_key_id     => Setting.aws_access_key_id,
  :secret_access_key => Setting.aws_secret_access_key

# action mailer config
ActionMailer::Base.default_content_type = "text/html"
#ActionMailer::Base.delivery_method = :smtp
# ActionMailer::Base.delivery_method = :test #:ses
ActionMailer::Base.delivery_method = :ses
ActionMailer::Base.default_charset = "utf-8"
ActionMailer::Base.default_url_options[:host] = "#{Setting.domain}"
ActionMailer::Base.raise_delivery_errors = true
