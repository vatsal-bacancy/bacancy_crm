module DirectoriesHelper

  def last_update(directory)
    document = directory.documents.present? ?  directory.documents.first : nil
    directories = directory.directories.present? ?  directory.directories.first : nil

    if document.present? || directories.present?
      document.present? ? (directories.present? ?  ((document.created_at < directories.created_at) ? directories.created_at.strftime("%m/%d/%Y, %I:%M %p") : document.created_at.strftime("%m/%d/%Y, %I:%M %p") )  : document.created_at.strftime("%m/%d/%Y, %I:%M %p") ) : directories.created_at.strftime("%m/%d/%Y, %I:%M %p")
    else
      directory.created_at.strftime("%m/%d/%Y, %I:%M %p")
    end

  end
end
