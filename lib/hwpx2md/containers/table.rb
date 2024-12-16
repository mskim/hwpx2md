require 'hwpx2md/containers/table_row'
require 'hwpx2md/containers/table_column'
require 'hwpx2md/containers/container'

module Hwpx2md
  module Elements
    module Containers
      #  table
      class Table
        include Container
        include Elements::Element

        def self.tag
          'tbl'
        end

        def initialize(node)
          @node = node
          @properties_tag = 'tblGrid'
        end

        # Array of row
        def rows
          @node.xpath('hp:tr').map { |r_node| Containers::TableRow.new(r_node) }
        end

        def row_count
          @node.xpath('hp:tr').count
        end

        # Array of column
        def columns
          columns_containers = []
          (0..(column_count - 1)).each do |i|
            columns_containers[i] = Containers::TableColumn.new @node.xpath("hp:tr//hp:tc[#{i + 1}]")
          end
          columns_containers
        end

        def column_count
          @node.xpath('hp:tblGrid/hp:gridCol').count
        end

        # Iterate over each row within a table
        def each_rows(&block)
          rows.each(&block)
        end
        
        # Get column alignments from the first row
        def column_alignments
          return [] if rows.empty?
          
          first_row = rows.first
          first_row.cells.map(&:horizontal_align)
        end

        # Check if table has a header row
        def has_header?
          return false if rows.empty?
          @node['repeatHeader'] == '1'
        end

        # Generate markdown alignment separator
        def alignment_separator
          alignments = column_alignments
          return "" if alignments.empty?
          
          separators = alignments.map do |align|
            case align
            when 'center'
              ':---:'
            when 'right'
              '---:'
            else # left or default
              ':---'
            end
          end
          
          "|#{separators.join('|')}|"
        end

        def to_markdown
          return '' if rows.empty?
          
          # Convert rows to markdown format
          table_rows = rows.map { |row| row.to_markdown }
          
          # If table has a header, add alignment separator after first row
          if has_header?
            table_rows.insert(1, alignment_separator)
          else
            # Add default left alignment separator
            separator = "|" + ([":---"] * column_count).join("|") + "|"
            table_rows.insert(1, separator)
          end
          
          # Join all rows with newlines and add extra newlines for readability
          "\n" + table_rows.join("\n") + "\n\n"
        end
        
        alias_method :to_txt, :to_markdown
        
      end
    end
  end
end
