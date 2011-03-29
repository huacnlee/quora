# coding: utf-8
class Authorization
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :provider
  field :uid
  embedded_in :user, :inverse_of => :authorizations
    
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
  
  def self.find_from_hash(hash)
    User.where("authorizations.provider" => hash['provider'],
                "authorizations.uid" => hash['uid']).first()
  end

  def self.create_from_hash(hash, user = nil)
    user ||= User.create_from_hash(hash)
    user.authorizations.create(:uid => hash['uid'], :provider => hash['provider'])
  end
end

