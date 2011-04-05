namespace :search do
  task :index => :environment do 
    print "Now indexing search to Redis..."
    Ask.all.each do |item|
      s = Search.new(:title => item.title, :id => item.id, :type => item.class)
      s.save
      print "."
    end
    Topic.all.each do |item|
      s = Search.new(:title => item.name, :id => item.id, :type => item.class)
      s.save
      print "."
    end
    User.all.each do |item|
      s = Search.new(:title => item.name, :id => item.id, :type => item.class)
      s.save
      print "."
    end
    puts "Done."
  end
end
