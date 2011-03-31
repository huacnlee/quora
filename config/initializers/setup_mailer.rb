ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :enable_starttls_auto => true,
  :port => 587,
  :domain => Setting.domain,
  :authentication => :plain,
  :user_name => Setting.smtp_username,
  :password => Setting.smtp_password
}
# action mailer config
ActionMailer::Base.default_content_type = "text/html"
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default_charset = "utf-8"
ActionMailer::Base.default_url_options[:host] = Setting.domain
ActionMailer::Base.raise_delivery_errors = true
