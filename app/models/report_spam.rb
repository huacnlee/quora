class ReportSpam
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel

  field :url
  field :descriptions, :type => Array, :default => []

  index :url

  def self.add(url, description, user_name)
    report = find_or_create_by(:url => url)
    report.descriptions << "#{user_name}:\n#{description}"
    report.save
  end
end
