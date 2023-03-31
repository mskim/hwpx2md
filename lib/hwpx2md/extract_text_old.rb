require "pry-byebug"

base_name = "section0.xml"
souce_xml = File.open(base_name, "r") { |f| f.read }
binding.pry

puts souce_xml
