class Notification
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :has_read, :type => Boolean, :default => false
  field :target_id
  field :action
  
  belongs_to :log
  belongs_to :user, :inverse_of => :notifications
  
  scope :unread, where(:has_read => false) 
end