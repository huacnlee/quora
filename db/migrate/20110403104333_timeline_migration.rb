class TimelineMigration < Mongoid::Migration
  def self.up
    Ask.all.each do |ask|
      begin
        log = AskLog.new
        log.user_id = ask.user_id
        log.title = ask.title
        log.ask = ask
        log.target_id = ask.id
        log.action = "NEW"
        log.diff = ""
        log.save

        log = AskLog.new
        log.user_id = ask.user_id
        log.title = ask.topics.join(',')
        log.ask = ask
        log.target_id = ask.id
        log.action = "ADD_TOPIC"
        log.target_parent_id = ask.id
        log.target_parent_title = ask.title
        log.diff = ""
        log.save
      rescue Exception => e
        
      end
    end
    
    Answer.all.each do |answer|
      begin
        log = AnswerLog.new
        log.user_id = answer.user_id
        log.title = answer.body
        log.answer = answer
        log.target_id = answer.id
        log.action = "NEW"
        log.target_parent_id = answer.ask_id
        log.target_parent_title = answer.ask.title
        log.diff = ""
        log.save
      rescue Exception => e
        
      end
    end
  end

  def self.down
  end
end