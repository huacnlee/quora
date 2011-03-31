CarrierWave.configure do |config|
  config.grid_fs_connection = Mongoid.database
  config.storage = :grid_fs
  config.grid_fs_access_url = Setting.upload_url
end
