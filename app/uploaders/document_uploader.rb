class DocumentUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  if Rails.env.development? || Rails.env.test?
    storage :file
  elsif Rails.env.production?
    storage :aws
  end
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename=(name)
    @filename = name
  end


  def rename(new_filename, options = {})
    return if !file || new_filename == file.filename
    target = File.join(store_path, new_filename)
    file.copy_to(target)

    # versions.keys.each do |k|
    #   if k == target
    #     target = File.join(store_path, "#{k}_#{new_filename}")
    #     version = send(k).file
    #     version.copy_to(target)
    #   end
    # end

    remove! unless options[:keep_original]
    model.update_column(mounted_as, new_filename) && model.reload

    # sf = model.attachment.file
    # new_path = File.join( File.dirname(path) , "#{new_name}")
    # new_sf = CarrierWave::SanitizedFile.new sf.move_to(new_path)
    # model.attachment.cache!(new_sf)
    # model.save!
    # return model

  end
  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_whitelist
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
