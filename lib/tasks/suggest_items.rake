namespace :suggest_items do
  task :refresh => :environment do 
    print "Now refresh suggest_items to Redis..."
    User.all.each do |item|
      item.refresh_suggest_items
      print "."
    end
    puts "Done."
  end
end
