# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

set :output, "/home/jason/wwwroot/quora/log/cronjobs.log"
# Learn more: http://github.com/javan/whenever
every 1.day, :at => "2:00 am" do
	command "cd /home/jason/wwwroot/quora/ && sh backup_mongodb"
end

every 1.hours do
	rake "mailer:ask_invite"
end
