class Notification
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zomet::InstanceMethods
  
  field :has_read, :type => Boolean, :default => false
  field :target_id
  field :action

  index :user_id
  index :has_read
  
  belongs_to :log
  belongs_to :user, :inverse_of => :notifications
  
  scope :unread, where(:has_read => false) 
  
  after_create :publish_to_owner
  
  def publish_to_owner
    return if self.user.nil?
    Rails.logger.info "publish_to_owner"
    load_zomet_config
    pub_to_browser({
      :channel => "/notifications/#{self.user.slug}", 
      :data_type => "text", 
      :data => "\"Hello from Ruby #{Time.now.strftime("%H:%M:%S")}\""
    })
  end
end
