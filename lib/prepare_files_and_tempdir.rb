require 'fileutils'

module PrepareFilesAndTempdir

  def clear_filename(filename)
    new_filename = filename.dup.downcase
    new_filename.gsub!(/\s+/, "_")        # whitespaces -> underscore
    new_filename.gsub!(/_{2,}/, "_")      # multiple underscores -> one underscore
    new_filename.gsub!(/\&/, "_and_")     # "&" -> "_and_"
    new_filename.gsub!(/\(|\)/, "")       # remove braces
    new_filename.gsub!(/_-_/, "-")        # "_-_" -> "-"
    new_filename.sub!(/\A_/, "")          # remove leading "_"
    new_filename.sub!(/kahvi\d*.{0,2}\_/, "")  # remove prefix from kahvi.org releases
    new_filename.gsub!(/\'/, "")          # remove '
    return new_filename
  end

  def remove_underscore_from_tag(tag_string)
    string = tag_string.gsub!(/_/, ' ')
    return string.nil? ? tag_string : string
  end

  def remove_path_from_filename(file)
    match = /\/([\w-]+.\w+)\z/.match(file)
    unless match.nil? then
      new_filename = match.captures.first
      #puts "nf:#{new_filename}"
      
      return new_filename
    else
      raise "Error: Could not remove path from #{file}"
    end
  end

  def add_tempdir_path_to_filename(file,tempdir)
    filename_with_path = "#{tempdir}/#{file}"
    return filename_with_path
  end

  # default is $HOME/tmp
  def create_tempdir!(dir)
    tempdir = dir.nil? ? "#{ENV['HOME']}/tmp" : dir
    FileUtils.mkdir_p(tempdir)
    return tempdir
  end

  def create_file_copy(file)
    copy = "copy-" + File.basename(file) # inserts "copy-" to filename
    copy = File.dirname(file) + "/#{copy}"
    FileUtils.copy(file, copy)
    return copy

  end

  def delete_symlink!(file)
    if File.ftype(file).eql?("link") then
      FileUtils.rm(file)
    else
      puts "#{file} was no symlink. It was a '#{File.ftype(file)}'."
    end
  end

  def create_symlink_in_tempdir(file_old_path,file,tempdir)
    file_new_path = add_tempdir_path_to_filename(file, tempdir)
    if file_new_path then
      unless File.exists?(file_new_path) then # maybe there was an error and symlink was not deleted
        file_old_path = "#{FileUtils.pwd}/#{file_old_path}" unless is_absolute_path?(file_old_path)
        FileUtils.ln_s(file_old_path, file_new_path)
      end
      return tempdir
    else
      raise "Error: Could not add tempdir path to #{file}"
    end
  end

  def is_absolute_path?(path)
    match = /\A\//.match(path)
    unless match.nil? then
      return true
    else
      return false
    end
  end

  def sometimes_remove_trailing_slash!(path)
    path.sub!(%r{/\z}, '')
  end

end

