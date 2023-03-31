require "pry-byebug"

base_name = "section0.xml"
souce_xml = File.open(base_name, "r") { |f| f.read }
binding.pry
# item_to_change = <<~EOF
# ^<\?xml (.|\n)*?</hp:secPr>
# <hp:footNote number="([0-9]*)" (.|\n)*?<hp:autoNum num="([0-9]*)" (.|\n)*?<hp:t>((.)*?)</hp:t>(.|\n)*?</hp:footNote> -> [^$1] "[^$3]:$5"
# <[/]?hp:ctrl>
# <[/]?hp:run>
# <hp:run (.)*?"[/]?>
# <[/]?hp:p>
# <hp:p (.)*?"[/]?>
# <hp:colPr (.)*?"[/]?>
# </hs:sec>
# <hp:pageNum (.)*?"[/]?>
# <hp:linesegarray>(.|\n)*?</hp:linesegarray> -> \n
# <hp:lineBreak/>  -> \n
# <[/]?hp:t>
# EOF

puts item_to_change

# item_to_change.each_line do |line|
#   binding.pry
#   if line.include?("->")
#     a = line.split("->")
#     souce_xml.gsub(/#{a[0]}/, /#{a[1]}/)
#   else
#     souce_xml.gsub(/#{line}/, "")
#   end
# end

puts souce_xml
