require File.dirname(File.expand_path(__FILE__)) + "/../test_helper"

describe Hwpx2md::Document do

  before do
    data_foloder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
    hwpx_path  = data_foloder + "/sample1.hwpx"
    @doc = Hwpx2md::Document.open(hwpx_path)
  end

  it "should create Hwpx2md::Document class" do
    assert_equal Hwpx2md::Document, @doc.class
  end

end

describe Hwpx2md::Document do

  before do
    data_foloder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
    hwpx_path  = data_foloder + "/sample1.hwpx"
    @doc = Hwpx2md::Document.new(hwpx_path)
  end

  it "should create Hwpx2md::Document class" do
    assert_equal Hwpx2md::Document, @doc.class
    assert_equal 39, @doc.paragraphs.length
  end

end
