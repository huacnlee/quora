class RecountUserAsksCount < Mongoid::Migration
  def self.up
    User.all.each do |u|
      u.asks_count = u.asks.count
      if u.save
        puts "Changed #{u.asks_count}"
      end
    end
  end

  def self.down
  end
end
