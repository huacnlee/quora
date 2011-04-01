# coding: UTF-8
require 'carrierwave/processing/mini_magick'
class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :grid_fs
  
  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end


  # TODO: 此处要想办法，开启了 open-uri 下载的因为文件名的问题无法通过验证
  # Allow image file extensions
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # def filename
  #   "#{Time.now.to_i}.jpg"
  # end

end

