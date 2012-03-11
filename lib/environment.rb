unless RUBY_VERSION == "1.8.7" then
  raise "Error: ruby version 1.8.7 required"
end

require File.dirname(__FILE__) + "/prepare_files_and_output_dir"
require File.dirname(__FILE__) + "/string_extension"
require "rubygems"
require "find"
# https://github.com/masterkain/rtaglib
# taglib >= 1.5 required
# gem install rtaglib --version 0.3.0
require 'tagfile/tagfile'

