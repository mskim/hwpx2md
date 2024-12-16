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
          @node.xpath('hp:tc').map {|c_node| Containers::TableCell.new(c_node) }
        end

        # Get cells with their spans taken into account
        def expanded_cells
          result = []
          current_cells = cells
          
          # Create a map of positions that are covered by spans
          skip_positions = {}
          current_cells.each do |cell|
            col, row = cell.position
            col_span, row_span = cell.spans
            
            # Mark positions that should be skipped due to spanning
            if cell.merged?
              (0...col_span).each do |c|
                (0...row_span).each do |r|
                  skip_positions[[col + c, row + r]] = true
                end
              end
            end
          end
          
          # Add cells or empty placeholders based on the skip map
          current_cells.each_with_index do |cell, idx|
            col, row = cell.position
            next if skip_positions[[col, row]]
            
            result << cell
          end
          
          result
        end

        def to_markdown
          "| " + expanded_cells.map { |cell| cell.to_markdown }.join(" | ") + " |"
        end

        alias_method :to_txt, :to_markdown
        
      end
    end
  end
end
