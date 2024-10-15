require 'nokogiri'
require 'debug'

xml_path = File.dirname(__FILE__) +  "/Contents/section0.xml"
xml = File.open(xml_path){|f| f.read}
@doc = Nokogiri::XML(xml)
paragraphs = @doc.xpath('hs:sec/hp:p')
puts paragraphs.length
paragraphs.each_with_index do |p, i|
  puts "P: #{i}"
  runs = p.xpath('hp:run')
  runs.each do |r|
    # children_nodes = r.xpath('hp:t|hp:tbl|hp:pic')
    children_nodes = r.children
    children_nodes.each do |child_node|
      if child_node.name = 't'
        if child_node.content == ""
        else
          puts "it is text"
          puts child_node.path
          puts child_node.content
        end
      elsif child_node.name = 'tbl'
        debugger
        puts "it is table"
        puts child_node.path
        puts child_node.content
      elsif child_node.name = 'pic'
        puts "it is image"
      elsif child_node.name = 'secPr'
        puts "it is secPr"
      elsif child_node.name = 'ctrl'
        puts "ctrl"
      end
    end
      # text_nodes = r.xpath('.//hp:t|.//hp:tbl|.//hp:pic')
      # text_nodes.each do  |t_node|
      #     puts t_node.path
      #     puts t_node.content
      # end
  end
end


