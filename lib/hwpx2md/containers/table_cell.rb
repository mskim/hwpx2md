require 'hwpx2md/containers/text_run'
require 'hwpx2md/containers/container'

module Hwpx2md
  module Elements
    module Containers
      class TableCell
        include Container
        include Elements::Element

        def self.tag
          'tc'
        end

        def initialize(node)
          @node = node
          @properties_tag = 'tcPr'
        end

        # Return text of paragraph's cell
        def to_s
          @node.xpath('.//hp:t').map(&:text).join('')
        end

        # Array of paragraphs contained within cell
        def paragraphs
          @node.xpath('.//hp:p').map {|p_node| Containers::Paragraph.new(p_node) }
        end

        # Iterate over each text run within a paragraph's cell
        def each_paragraph
          paragraphs.each { |tr| yield(tr) }
        end
        
        alias_method :text, :to_s

        # Get vertical alignment of the cell
        def vertical_align
          sublist = @node.at_xpath('hp:subList')
          sublist ? sublist['vertAlign']&.downcase : 'center'
        end

        # Get horizontal alignment of the cell
        def horizontal_align
          paragraph = paragraphs.first
          return 'left' unless paragraph
          
          para_align = paragraph.instance_variable_get(:@node)&.at_xpath('hp:pPr')&.[]('align')&.downcase
          para_align || 'left'
        end

        # Get cell span information
        def spans
          span_node = @node.at_xpath('hp:cellSpan')
          return [1, 1] unless span_node
          
          col_span = span_node['colSpan']&.to_i || 1
          row_span = span_node['rowSpan']&.to_i || 1
          [col_span, row_span]
        end

        # Check if cell is merged
        def merged?
          spans[0] > 1 || spans[1] > 1
        end

        # Get cell position
        def position
          addr_node = @node.at_xpath('hp:cellAddr')
          return [0, 0] unless addr_node
          
          col = addr_node['colAddr']&.to_i || 0
          row = addr_node['rowAddr']&.to_i || 0
          [col, row]
        end

        # Return text with proper escaping for markdown table cells
        def to_markdown
          content = text.strip
          content = content.gsub('|', '\\|') # Escape pipe characters
          content = '&nbsp;' if content.empty? # Use non-breaking space for empty cells
          content
        end

      end
    end
  end
end
