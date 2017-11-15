# encoding: utf-8

class ProductUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{Rails.root}/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_to_fit => [312, 312]
  end
  
  version :thumb400 do
    process :resize_and_pad => [400, 400, "#FFFFFF", "Center"]
  end

  version :thumb250 do
    process :resize_and_pad => [250, 250, "#FFFFFF", "Center"]
  end

  version :thumb214 do
    process :resize_and_pad => [214, 214, "#FFFFFF", "Center"]
  end

  version :thumb200 do
    process :resize_and_pad => [200, 200, "#FFFFFF", "Center"]
  end

  version :thumb170 do
    process :resize_and_pad => [170, 170, "#FFFFFF", "Center"]
  end

  version :thumb100 do
    process :resize_and_pad => [100, 100, "#FFFFFF", "Center"]
  end

  version :thumb80 do
    process :resize_and_pad => [80, 80, "#FFFFFF", "Center"]
  end

  version :thumb60 do
    process :resize_and_pad => [60, 60, "#FFFFFF", "Center"]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
