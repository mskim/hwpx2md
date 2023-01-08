module Hwpx2md
  module Elements
    module Containers
      class FootnoteNode
        include Container
        include Elements::Element
        
        attr_reader :paragraph
        
        def initialize(node, document_properties = {})
          @node = node
          @properties_tag = 'hp:footNote'
          @document_properties = document_properties
          @font_size = @document_properties[:font_size]
        end   

        def to_txt
          "[^1]"
        end
      end

    end
  end
end