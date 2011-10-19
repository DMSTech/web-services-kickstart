
require 'mime/types'

class FileUtilities

  # Returns the mime-type of the given file format
  def self.get_mime_type(file_format)
    if( !file_format.nil? and !file_format.empty? )
      file_type = MIME::Types.type_for(file_format).first
      file_type.content_type unless file_type.nil?
    end
  end

end

