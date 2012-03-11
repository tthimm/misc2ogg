#!/usr/bin/env ruby
require File.dirname(__FILE__) + "/environment"

# TODO: check start parameters: "-s" needs file, "-f" needs format, "-r -s" wat, etc

# TODO: add quality profiles (HQ, LQ, ...)
# TODO: add output formats
# TODO: add output directory option (check permissions!)

class Encode
  include PrepareFilesAndOutputDir

  PROFILE = {:ogg => "-acodec libvorbis -ac 2 -ar 44100 -ab 128k -vn",
   :mp3 => "-acodec libmp3lame -ac 2 -ar 44100 -ab 128k -vn"}

  attr_reader :input, :format, :outpath
  attr_accessor :output

  def initialize(input,format="mp3",outpath="#{ENV['HOME']}/tmp")
    @input  = input
    @format = format.to_sym
    @outpath = outpath
  end

  def run_encoding
    unless PROFILE.has_key?(@format) then
      puts "Output to #{@format} not supported. See help (--help, -h) for supported formats."
      Process.exit(false)
    end
    new_filename, path = prepare_files_and_output_dir(@outpath, @input)
    @output = add_output_dir_path_to_filename(new_filename.sub(/\A\./, ''), path)
    @output = add_new_extension(self.output)
    new_filename = add_output_dir_path_to_filename(new_filename, path)
    convert_file(new_filename, @output)
    delete_symlink!(new_filename)
    create_file_tags!
  end

  private

  def self.show_supported_output_formats
    puts "Supported formats: #{PROFILE.keys.join(', ')}"
  end

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

  def self.show_help_message
    puts "Usage: #{File.basename(__FILE__)}  [switches]"
    puts "  --single           (-s) encode single file"
    puts "  --recursive        (-r) encode content of directory recursively"
    puts "  --format           (-f) optional, define output format, defaults to 'mp3'"
    #puts "  --output           (-o) optional, define output folder, defaults to $HOME/tmp"
    puts "  --display_formats  (-d) show supported output formats"
    puts "  --help             (-h) show help message"
    puts "  --version          (-v) show program version"
    puts ""
    puts "Report bugs to        <thimm.t@gmail.com>"
    puts "misc2ogg website      <https://github.com/tthimm/misc2ogg>"
    Process.exit
  end

  def convert_file(input,output)
    `ffmpeg -y -i #{input} #{PROFILE[@format]} #{output}`
  end

  def add_new_extension(filename)
    filename.sub(/\.\w{1,3}\z/, ".#{@format}")
  end

  def self.has_allowed_extension?(file)
    allowed = ["mp3", "flv", "mp4", "ogg", "divx", "avi"]
    allowed.include?(File.extname(file.downcase).sub(/\./, ''))
  end


end

def parameter_index(param1, param2=nil)
  if ARGV.include?(param1) then
    return ARGV.index(param)
  end
  unless param2.nil?
    return ARGV.index(param2)
  end
end

# user specified output format
if ARGV.include?("--format") || ARGV.include?("-f") then
  index = ARGV.index("-f").nil? ? ARGV.index("--format") : ARGV.index("-f")
  format = ARGV[index + 1]
end

# batch encoding of current directory
if ARGV.include?("--recursive") || ARGV.include?("-r") then
  file_list = []
  Find.find("./") do |file|
    unless File.directory?(file) then
      if Encode.has_allowed_extension?(file) then
        file_list << file
      end
    end
  end
  file_list.each do |f|
    encode = Encode.new(f) if format.nil?
    encode = Encode.new(f, format) if !format.nil?
    encode.run_encoding
  end
# see help
elsif ARGV.include?("--help") || ARGV.include?("-h") then
  Encode.show_help_message
# see supported formats
elsif ARGV.include?("--display_formats") || ARGV.include?("-d") then
  Encode.show_supported_output_formats
# encoding of single file
elsif ARGV.include?("--single") || ARGV.include?("-s") then
  encode = Encode.new(ARGV[parameter_index("--single", "-s") + 1]) if format.nil?
  encode = Encode.new(ARGV[parameter_index("--single", "-s") + 1], format) if !format.nil?
  encode.run_encoding
else
  Encode.show_help_message
end

