# coding: utf-8
class Authorization
  include Mongoid::Document
  
  field :provider
  field :uid
  embedded_in :user, :inverse_of => :authorizations

  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
  
  def self.find_from_hash(hash)
    uid = hash['uid']
    uid = hash['user_info']['username'] if uid.blank?
    User.where("authorizations.provider" => hash['provider'],
                "authorizations.uid" => uid).first()
  end

  def self.create_from_hash(hash, user = nil)
    user ||= User.create_from_hash(hash)
    uid = hash['uid']
    uid = hash['user_info']['username'] if uid.blank?
    a = new(:uid => uid, :provider => hash['provider'])
    user.authorizations << a
    if a.save
      Rails.logger.debug { "authorization saved." }
    else
      Rails.logger.error { a.errors }
    end
    user
  end
end

