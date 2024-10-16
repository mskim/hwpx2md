
require 'zip/zip'

def unzip_hwpx(hwpc_file_path)
  file_name = File.basename(hwpc_file_path, '.hwpx')
  dest = File.dirname(hwpc_file_path) + "/#{file_name}"
  Zip::ZipFile.open(hwpc_file_path) { |zip_file|
    zip_file.each { |f|
      f_path=File.join(dest, f.name)
      FileUtils.mkdir_p(File.dirname(f_path))
      zip_file.extract(f, f_path) unless File.exist?(f_path)
    }
  }
end


hwpc_folder = File.dirname(__FILE__)
# Dir["#{hwpc_folder}/*.hwpx"].each do |hwpx|
#   unzip_hwpx(hwpx)
# end

hwpc_file_path = hwpc_folder + "/sample_math.hwpx"
unzip_hwpx(hwpc_file_path)
