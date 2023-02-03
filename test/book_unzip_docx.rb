require 'zip'
require 'nokogiri'
require 'pry-byebug'

hwpx_path = 'paul.hwpx'

Zip::File.open(hwpx_path) do |zip_file|
  zip_file.each do |f|
    f_path = File.join("destination_path", f.name)
    FileUtils.mkdir_p(File.dirname(f_path))
    zip_file.extract(f, f_path) unless File.exist?(f_path)
  end
end
