
require 'zip/zip'
require 'Hwpx2md'
require 'debug'
def save_as_txt(hwpx_file_path)
  txt_file = Hwpx2md::Document.new(hwpx_file_path).to_txt
  txt_path = hwpc_file_path.sub('.hwpx', '.txt')
  File.open(txt_path, 'w'){|f| f.write txt_file}
end

hwpx_folder = File.dirname(__FILE__)
Dir["#{hwpx_folder}/*.hwpx"].each do |hwpx|
  puts hwpx_path = File.expand_path(hwpx)
  debugger #unless File.exist?(hwpx_path)
  save_as_txt(hwpx_path)
end