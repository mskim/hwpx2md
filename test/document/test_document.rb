require File.dirname(File.expand_path(__FILE__)) + "/../test_helper"

# describe Hwpx2md::Document do

#   before do
#     data_foloder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
#     hwpx_path  = data_foloder + "/sample1.hwpx"
#     @doc = Hwpx2md::Document.open(hwpx_path)
#     @txt_path = data_foloder + "/sample1.txt"
#   end

#   it "should create Hwpx2md::Document class" do
#     assert_equal Hwpx2md::Document, @doc.class
#   end

#   it "should create Hwpx2md::Document class" do
#     assert_equal String, @doc.to_txt.class
#   end

#   it "should create Hwpx2md::Document class" do
#     File.open( @txt_path, 'w'){|f| f.write @doc.to_txt}
#     assert File.exist?(@txt_path)
#     system "open #{@txt_path}"
#   end
# end

# describe Hwpx2md::Document do
#   before do
#     data_foloder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
#     hwpx_path  = data_foloder + "/sample_table.hwpx"
#     @doc = Hwpx2md::Document.open(hwpx_path)
#     @txt_path = data_foloder + "/sample_table.txt"
#   end

#   it "should create Hwpx2md::Document class" do
#     assert_equal Hwpx2md::Document, @doc.class
#   end

#   it "should create Hwpx2md::Document class" do
#     assert_equal String, @doc.to_txt.class
#   end

#   it "should create Hwpx2md::Document class" do
#     File.open( @txt_path, 'w'){|f| f.write @doc.to_txt}
#     assert File.exist?(@txt_path)
#     system "open #{@txt_path}"
#   end
# end


describe Hwpx2md::Document do
  before do
    data_foloder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
    hwpx_path  = data_foloder + "/sample_math.hwpx"
    @doc = Hwpx2md::Document.open(hwpx_path)
    @txt_path = data_foloder + "/sample_math.txt"
  end

  it "should create Hwpx2md::Document class" do
    assert_equal Hwpx2md::Document, @doc.class
  end

  it "should create Hwpx2md::Document class" do
    assert_equal String, @doc.to_txt.class
  end

  it "should create Hwpx2md::Document class" do
    File.open( @txt_path, 'w'){|f| f.write @doc.to_txt}
    assert File.exist?(@txt_path)
    system "open #{@txt_path}"
  end
end