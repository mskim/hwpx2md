require 'nokogiri'
require 'debug'

xml_path = File.dirname(__FILE__) +  "/Contents/section0.xml"
xml = File.open(xml_path){|f| f.read}
@doc = Nokogiri::XML(xml)
paragraphs = @doc.xpath('//hs:sec//hp:p')
puts paragraphs.length
paragraphs.each_with_index do |p, i|
  puts "P: #{i}"
  runs = p.xpath('.//hp:run')
  runs.each do |r|
    if text_node = r.xpath('hp:t').first
      puts text_node.path
      puts text_node.content
    end
    if table_nodes = r.xpath('run/hp:tbl').first
      puts "it is table"
      puts text_node.path
      puts text_node.content
    end
    if image_nodes = r.xpath('hp:pic').first
      puts "it is image"
    end
      # text_nodes = r.xpath('.//hp:t|.//hp:tbl|.//hp:pic')
      # text_nodes.each do  |t_node|
      #     puts t_node.path
      #     puts t_node.content
      # end
  end
end


