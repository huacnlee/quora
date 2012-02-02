require "resque"
class BaseMailer < ActionMailer::Base
  # include Resque::Mailer
  default :sender => Setting.email_sender
  helper :application,:users,:asks
  layout "mailer"
end
