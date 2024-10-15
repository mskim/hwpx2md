require 'nokogiri'

xml_path = File.dirname(__FILE__) +  "/Contents/section0.xml"
xml = File.open(xml_path){|f| f.read}
@doc = Nokogiri::XML(xml)
paragraphs = @doc.xpath('//hs:sec//hp:p')
puts paragraphs.length
debugger
paragraphs.each do |p|
  # puts "-------- new paragraph ---------"
  runs = p.xpath('.//hp:run')
  runs.each do |r|
    text_nodes = r.xpath('.//hp:t|.//hp:ctrl//hp:footNote|.//hp:ctrl//hp:t')
    # text_nodes.each do |t_node|
    #   # puts t_node.content
    #   # puts t_node.path
    # end
  end
end


