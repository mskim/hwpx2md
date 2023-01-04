require 'docx2md/containers/container'

module Docx2md
  module Elements
    module Containers
      class TextRun
        include Container
        include Elements::Element

        DEFAULT_FORMATTING = {
          italic:    false,
          bold:      false,
          underline: false
        }

        def self.tag
          'r'
        end

        attr_reader :text
        attr_reader :formatting
        attr_reader :footnote_id, :footnote_reference

        def initialize(node, document_properties = {})
          @node = node
          @text_nodes = @node.xpath('w:t').map {|t_node| Elements::Text.new(t_node) }
          @text_nodes = @node.xpath('w:t|w:r/w:t').map {|t_node| Elements::Text.new(t_node) }

          @properties_tag = 'rPr'
          @text       = parse_text || ''
          @formatting = parse_formatting || DEFAULT_FORMATTING
          @document_properties = document_properties
          @font_size = @document_properties[:font_size]
        end

        # Set text of text run
        def text=(content)
          if @text_nodes.size == 1
            @text_nodes.first.content = content
          elsif @text_nodes.empty?
            new_t = Elements::Text.create_within(self)
            new_t.content = content
          end
          reset_text
        end

        # Returns text contained within text run
        def parse_text
          @text_nodes.map(&:content).join('')
        end

        # Substitute text in text @text_nodes
        def substitute(match, replacement)
          @text_nodes.each do |text_node|
            text_node.content = text_node.content.gsub(match, replacement)
          end
          reset_text
        end

        def parse_formatting
          {
            italic:    !@node.xpath('.//w:i').empty?,
            bold:      !@node.xpath('.//w:b').empty?,
            underline: !@node.xpath('.//w:u').empty?,
          }
        end

        def to_s
          @text
        end

        # Return text as a HTML fragment with formatting based on properties.
        def to_html
          html = @text
          html = html_tag(:em, content: html) if italicized?
          html = html_tag(:strong, content: html) if bolded?
          styles = {}
          styles['text-decoration'] = 'underline' if underlined?
          # No need to be granular with font size down to the span level if it doesn't vary.
          styles['font-size'] = "#{font_size}pt" if font_size != @font_size
          html = html_tag(:span, content: html, styles: styles) unless styles.empty?
          html = html_tag(:a, content: html, attributes: {href: href, target: "_blank"}) if hyperlink?
          return html
        end
        
        def to_markdown
          v_align_node = @node.at_xpath('.//w:vertAlign')
          if v_align_node
            align_value = v_align_node.attribute('val').value
            if align_value == 'superscript'
              reference_node = @node.at_xpath('w:footnoteReference')
              footnote_id = reference_node.attribute('id').value
              markdown = "[^#{footnote_id}]"
              return markdown
            else
              # handle subscript
            end
          end

          markdwon = @text
          if italicized?
            "*" + markdwon + "*"
          elsif bolded?
            "**" + markdwon + "**"
          end
          markdwon
        end

        def has_footnote?
          !@footnote_id.nil?
        end

        def italicized?
          @formatting[:italic]
        end

        def bolded?
          @formatting[:bold]
        end

        def underlined?
          @formatting[:underline]
        end

        def hyperlink?
          @node.name == 'hyperlink'
        end

        def href
          @document_properties[:hyperlinks][hyperlink_id]
        end

        def hyperlink_id
          @node.attributes['id'].value
        end

        def font_size
          size_tag = @node.xpath('w:rPr//w:sz').first
          size_tag ? size_tag.attributes['val'].value.to_i / 2 : @font_size
        end

        private

        def reset_text
          @text = parse_text
        end
      end
    end
  end
end
