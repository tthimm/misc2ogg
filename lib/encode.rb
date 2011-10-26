#!/usr/bin/env ruby
unless RUBY_VERSION == "1.8.7" then
  raise "Error: ruby version 1.8.7 required"
end

require File.dirname(__FILE__) + "/prepare_files_and_tempdir"
require File.dirname(__FILE__) + "/string_extension"
require File.dirname(__FILE__) + "/exceptions"
require "rubygems"
require "find"

# https://github.com/masterkain/rtaglib
# gem install rtaglib --version 0.2.3
require 'tagfile/tagfile'

class Encode
  include PrepareFilesAndTempdir

  PROFILE = {:ogg => "-acodec libvorbis -ac 2 -ar 44100 -ab 128k -vn",
   :mp3 => "-acodec libmp3lame -ac 2 -ar 44100 -ab 128k -vn"}

  attr_reader :input, :format
  attr_accessor :output

  def initialize(input,format="mp3")
    @input  = input
    @format = format.to_sym
  end

  def run_encoding
    unless PROFILE.has_key?(@format) then
      raise UnsupportedException, "Output to #{@format} not supported. Supported: #{supported_formats}"
    end
    new_filename, path = prepare_files_and_tempdir(nil)
    @output = add_tempdir_path_to_filename(new_filename, path)
    @output = add_new_extension(self.output)
    new_filename = add_tempdir_path_to_filename(new_filename, path)
    convert_file(new_filename, @output)
    delete_symlink!(new_filename)
    create_file_tags!
  end

  private

  def create_file_tags!
    artist, title = File.basename(@output, @format.to_s).split("-")
    copy = create_file_copy(@output)
    tag = TagFile::File.new(copy)
    tag.artist = remove_underscore_from_tag(artist)
    tag.title = remove_underscore_from_tag(title.chop!) unless title.nil?
    tag.save
    FileUtils.rm(@output)
    FileUtils.mv(copy, @output)
  end

  def supported_formats
    return PROFILE.keys.join(', ')
  end

  def show_usage_message
    puts " Usage: '#{File.basename(__FILE__)} <input> [format]'"
    puts " format is optional, defaults to \"ogg\""
  end

  def convert_file(input,output)
    `ffmpeg -y -i #{input} #{PROFILE[@format]} #{output}`
  end

  def prepare_files_and_tempdir(temp)
    file_without_path = remove_path_from_filename(clear_filename(@input))
    tempdir = create_tempdir!(temp)
    sometimes_remove_trailing_slash!(tempdir)
    new_path = create_symlink_in_tempdir(@input, file_without_path, tempdir)
    return file_without_path, new_path
  end

  def add_new_extension(filename)
    filename.sub(/\.\w{1,3}\z/, ".#{@format}")
  end


end

def has_allowed_extension?(file)
  allowed = [".mp3", ".flv", ".mp4", ".ogg", ".divx", ".avi"]
  allowed.include?(File.extname(file.downcase))
end

unless ARGV.empty? then
  encode = Encode.new(ARGV[0], ARGV[1]) if ARGV[0] && ARGV[1]
  encode = Encode.new(ARGV[0]) if ARGV[0] && !ARGV[1]
  encode.run_encoding
#end
else # batchencoding
  file_list = []
  Find.find("./") do |file|
    unless File.directory?(file) then
      if has_allowed_extension?(file) then
        file_list << file
      end
    end
  end
  file_list.each do |f|
    encode = Encode.new(f)
    encode.run_encoding
  end
end

