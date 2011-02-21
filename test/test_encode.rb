require File.dirname(__FILE__) + "/test_helper"
require "encode"

class TestEncode < Test::Unit::TestCase

  def setup
    @file = File.dirname(__FILE__) + "/fixtures/DTMF-DelayEd.wav"
  end

  def test_create_file_tags
    encode = Encode.new(@file)
    encode.run_encoding
    assert File.exists?(ENV['HOME'] + "/tmp/dtmf-delayed.ogg")
    tag = TagFile::File.new(ENV['HOME'] + "/tmp/dtmf-delayed.ogg")
    assert_equal "dtmf", tag.artist
    assert_equal "delayed", tag.title
    #assert File.exists?(ENV['HOME'] + "/tmp/copy-dtmf-delayed.ogg")
  end

end

