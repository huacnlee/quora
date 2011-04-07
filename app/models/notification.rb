class Notification
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :has_read, :type => Boolean, :default => false
  
  belongs_to :log
  belongs_to :user
end