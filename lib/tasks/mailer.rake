namespace :mailer do
  task :ask_invite => :environment do 
    AskInvite.check_to_send
  end
end
