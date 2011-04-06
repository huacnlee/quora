class TotalUserAnsweredAskIds < Mongoid::Migration
  def self.up
    User.all.each do |u|
      begin
        u.answered_ask_ids = u.answers.collect { |a| a.ask_id }
        u.save
      rescue
      end
    end
  end

  def self.down
  end
end
