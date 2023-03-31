require "pry-byebug"

base_name = "section0.xml"
souce_xml = File.open(base_name, "r") { |f| f.read }
souce_xml.gsub!(%r{^<\?xml (.|\\n)*?</hp:secPr>}m, "")
# souce_xml.gsub!(/m, //
# fix footnote here using string.scan
souce_xml.gsub!(
  %r{<hp:footNote number="([0-9]*)" (.|\\n)*?<hp:autoNum num="([0-9]*)" (.|\\n)*?<hp:t>((.)*?)</hp:t>(.|\\n)*?</hp:footNote>},
  "++++some footnote+++"
)
souce_xml.gsub!(%r{<[/]?hp:ctrl>}, "")
souce_xml.gsub!(%r{<[/]?hp:run>}, "")
souce_xml.gsub!(%r{<hp:run (.)*?"[/]?>}, "")
souce_xml.gsub!(%r{<[/]?hp:p>}, "")
souce_xml.gsub!(%r{<hp:p (.)*?"[/]?>}, "")
souce_xml.gsub!(%r{<hp:colPr (.)*?"[/]?>}, "")
souce_xml.gsub!(%r{</hs:sec>}, "")
souce_xml.gsub!(%r{<hp:pageNum (.)*?"[/]?>}, "")
souce_xml.gsub!(%r{<hp:linesegarray>(.|\\n)*?</hp:linesegarray>}, "\n")
souce_xml.gsub!(%r{<hp:lineBreak/>}, "\n")
souce_xml.gsub!(%r{<[/]?hp:t>}, "")
#

#   -> \n
#

puts souce_xml
