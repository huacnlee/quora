# coding: utf-8
class AskInvite
  include Mongoid::Document

  belongs_to :ask
  belongs_to :user
  # 多少人邀请
  field :count, :type => Integer, :default => 0
  # 邀请者
  field :invitor_ids, :type => Array, :default => []

  index :ask_id

  def self.invite(ask_id,user_id,invitor_id)
    item = find_or_create_by(:ask_id => ask_id,:user_id => user_id)
    item.invitor_ids ||= []
    item.count ||= 0
    return item if item.invitor_ids.include?(invitor_id)
    item.invitor_ids << invitor_id
    item.count += 1
    item.save
    UserMailer.invite_to_answer(ask_id, user_id, invitor_id).deliver
    item
  end

  def self.cancel(id, invitor_id)
    item = find(id)
    return 0 if item.blank?
    item.invitor_ids.delete(invitor_id)
    item.count -= 1
    if item.invitor_ids.blank?
      item.destroy
    else
      item.save
    end
    return 1
  end
end
