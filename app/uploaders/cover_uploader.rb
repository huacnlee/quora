class CoverUploader < BaseUploader
  def default_url
    "cover/#{version_name}.jpg"
  end

  version :small do
    process :resize_to_fit => [25, 25]
  end
  
  version :normal do
    process :resize_to_fit => [100, 100]
  end
  
end
