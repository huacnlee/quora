Resque::Server.use(Rack::Auth::Basic) do |user, password|
  Setting.admin_emails.include?(user) == true
end
