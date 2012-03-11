require 'fileutils'

module PrepareFilesAndOutputDir

  def clear_filename(filename)
    new_filename = filename.dup.downcase
    new_filename.gsub!(/\s+/, "_")        # whitespaces -> underscore
    new_filename.gsub!(/\&/, "_and_")     # "&" -> "_and_"
    new_filename.gsub!(/\!/, "")          # "!" -> ""
    new_filename.gsub!(/\(|\)/, "")       # remove braces
    new_filename.gsub!(/_-_/, "-")        # "_-_" -> "-"
    new_filename.sub!(/\A_/, "")          # remove leading "_"
    new_filename.sub!(/kahvi\d*.{0,2}\_/, "")  # remove prefix from kahvi.org releases
    new_filename.gsub!(/\'/, "")          # remove "'"
    new_filename.gsub!(/_{2,}/, "_")      # multiple underscores -> one underscore
    return new_filename
  end

  def remove_underscore_from_tag(tag_string)
    string = tag_string.gsub!(/_/, ' ')
    return string.nil? ? tag_string : string
  end

  def add_output_dir_path_to_filename(file,outdir)
    filename_with_path = "#{outdir}/#{file}"
    return filename_with_path
  end

  # default is $HOME/tmp
  def sometimes_create_output_dir!(outdir)
    FileUtils.mkdir_p(outdir)
    return outdir
  end

  def create_file_copy(file)
    copy = "copy-" + File.basename(file) # prepends "copy-" to filename
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

  def create_symlink_in_output_dir(file_old_path,file,outdir)
    file_new_path = add_output_dir_path_to_filename(file, outdir)
    if file_new_path then
      unless File.exists?(file_new_path) then # maybe there was an error and symlink was not deleted
        file_old_path = "#{FileUtils.pwd}/#{file_old_path}" unless is_absolute_path?(file_old_path)
        FileUtils.ln_s(file_old_path, file_new_path)
      end
      return outdir
    else
      raise "Error: Could not add output directory path to #{file}"
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

  def prepare_files_and_output_dir(path, input)
    file_without_path = File.basename(clear_filename(input))
    file_without_path = '.' + file_without_path
    outdir = sometimes_create_output_dir!(path)
    sometimes_remove_trailing_slash!(outdir)
    new_path = create_symlink_in_output_dir(input, file_without_path, outdir)
    return file_without_path, new_path
  end

end

