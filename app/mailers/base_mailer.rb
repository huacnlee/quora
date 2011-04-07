require "resque"
class BaseMailer < ActionMailer::Base
  include Resque::Mailer
  default :sender => Setting.smtp_username
  helper :application,:users,:asks
  layout "mailer"
end
