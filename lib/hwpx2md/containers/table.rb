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
          @node.xpath('w:tr').map { |r_node| Containers::TableRow.new(r_node) }
        end

        def row_count
          @node.xpath('w:tr').count
        end

        # Array of column
        def columns
          columns_containers = []
          (0..(column_count - 1)).each do |i|
            columns_containers[i] = Containers::TableColumn.new @node.xpath("w:tr//w:tc[#{i + 1}]")
          end
          columns_containers
        end

        def column_count
          @node.xpath('w:tblGrid/w:gridCol').count
        end

        # Iterate over each row within a table
        def each_rows(&block)
          rows.each(&block)
        end
      end
    end
  end
end
