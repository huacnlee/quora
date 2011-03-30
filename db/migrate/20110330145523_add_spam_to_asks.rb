class AddSpamToAsks < Mongoid::Migration
  def self.up
    Ask.all.each do |ask|
      ask.spams_count = 0
      ask.spam_voter_ids = []
      ask.save
    end
  end

  def self.down
  end
end
