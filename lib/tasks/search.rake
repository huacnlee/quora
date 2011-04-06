namespace :search do
  task :index => :environment do 
    print "Now indexing search to Redis..."
    Ask.all.each do |item|
      item.create_search_index
      print "."
    end
    Topic.all.each do |item|
      item.create_search_index
      print "."
    end
    User.all.each do |item|
      item.create_search_index
      print "."
    end
    puts "Done."
  end
end
