require 'hwpx2md/containers/table_cell'
require 'hwpx2md/containers/container'

module Hwpx2md
  module Elements
    module Containers
      class TableRow
        include Container
        include Elements::Element

        def self.tag
          'tr'
        end

        def initialize(node)
          @node = node
          @properties_tag = ''
        end

        # Array of cells contained within row
        def cells
          @node.xpath('w:tc').map {|c_node| Containers::TableCell.new(c_node) }
        end
        
      end
    end
  end
end
