
class DigitalStacks

  STACKS_DATA_STORE = '/stacks'
  DRUID_FROM_PATH_REGEX = /#{STACKS_DATA_STORE}\/([a-z]{2})\/(\d{3})\/([a-z]{2})\/(\d{4})/

  # Returns true or false based on whether the given filename exists in the digital stacks
  def self.exists?(id,filename)
    jp2_file_path = get_stacks_file_path(id,filename)
    if( jp2_file_path.nil? or !File.exist? jp2_file_path )
      return false
    end
    true
  end

  # Returns the absolute file path of the given file relative to the digital stacks data storage
  # root and the pair tree directory structure generated using the given object identifier
  def self.get_stacks_file_path(id,filename)
    pair_tree = create_pair_tree(id)
    file_ext = File.extname(filename)
    if( file_ext.nil? or file_ext.empty? )
      jp2_filename = filename + '.jp2'
    else
      jp2_filename = filename.gsub(File.extname(filename),'.jp2')
    end
    return File.join(STACKS_DATA_STORE,pair_tree,jp2_filename) if !pair_tree.nil? and !jp2_filename.nil?
    nil
  end
  
  def self.base_filename_from_stacks_file_path(stacks_file_path)
    stacks_file_path.split('/').last.split('.jp2').first
  end
  
  def self.id_from_stacks_file_path(stacks_file_path)
    if(stacks_file_path =~ DRUID_FROM_PATH_REGEX)
      return "#{$1}#{$2}#{$3}#{$4}"
    else
      return ''
    end
  end
  # Returns the pair tree directory structure based on the given object identifier.
  # The object identifier must be of the following format, otherwise nil is returned.
  #
  #     druid:xxyyyxxyyyy
  #
  #       where 'x' is an alphabetic character
  #       where 'y' is a numeric character
  #
  def self.create_pair_tree(id)
    id.gsub!('druid:','')
    if(id =~ /^([a-z]{2})(\d{3})([a-z]{2})(\d{4})$/)
      return File.join($1, $2, $3, $4)
    end
    nil
  end

end

