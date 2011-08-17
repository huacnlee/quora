namespace :search do
  task :index => :environment do 
    print "Now indexing search to Redis..."
    Ask.all.each do |item|
      item.redis_search_index_create
			item = nil
      print "."
    end
    Topic.all.each do |item|
      item.redis_search_index_create
			item = nil
      print "."
    end
    User.all.each do |item|
      item.redis_search_index_create
			item = nil
      print "."
    end
    puts "Done."
  end
end
