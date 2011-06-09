class Inbox
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id"

  field :body
  field :unread, :type => Boolean, :default => true
  embeds_many :replies, :class_name => "InboxReply", :inverse_of => :inbox

  index :user_id, :sender_id

  validates_presence_of :user_id, :sender_id, :body
  

  def self.find_by_user_id(user_id)
    any_of({:user_id => user_id}, {:sender_id => user_id}).desc(:created_at)
  end

  # 发送站内信
  def self.send(sender_id,to_user_id,body)
    item = new(:user_id => to_user_id,:sender_id => sender_id, :body => body)
    item.save
    item
  end

  # 回复
  def reply(user_id, body)
    self.replies.build(:user_id => user_id, :body => body)
    self.unread = true
    self.save
  end

  def read
    self.unread = false
    self.save
  end
end

class InboxReply
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :inbox
  belongs_to :user
  field :body
end
