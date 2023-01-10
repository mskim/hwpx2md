require File.dirname(File.expand_path(__FILE__)) + "/test_helper"

describe 'parse paul_and_j.hwpx' do
  before do
    # @hwpx_path = File.dirname(__FILE__) + '/book.hwpx'
    # @txt_path = File.dirname(__FILE__) + '/book.txt'
    @hwpx_path = File.dirname(__FILE__) + '/paul_and_j.hwpx'
    @txt_path = File.dirname(__FILE__) + '/paul_and_j.txt'
    doc = Hwpx2md::Document.open(@hwpx_path)
    txt = doc.to_txt
    File.open(@txt_path,'w'){|f| f.write txt }
  end

  it 'should sace md file' do
    assert File.exist?(@txt_path) 
  end

end


# describe 'parse dosword.hwpx' do
#   before do
#     @hwpx_path = File.dirname(__FILE__) + '/dosword.hwpx'
#     @txt_path = File.dirname(__FILE__) + '/dosword.txt'
#     doc = Hwpx2md::Document.open(@hwpx_path)
#     txt = doc.to_txt
#     File.open(@txt_path,'w'){|f| f.write txt }
#   end

#   it 'should sace md file' do
#     assert File.exist?(@txt_path) 
#   end

# end