# frozen_string_literal: true

module Hwpx2md
  module Elements
    module Containers
      # Represents an image element in HWPX document
      # HWPX stores images in BinData/ folder with references via hp:pic elements
      class ImageNode
        include Container
        include Elements::Element

        attr_reader :bin_item_id, :width, :height, :caption

        # Initialize from hp:pic XML node
        #
        # @param node [Nokogiri::XML::Node] The hp:pic element
        # @param options [Hash] Additional options
        # @option options [Hash] :bin_items Map of binItemIDRef to file info
        def initialize(node, options = {})
          @node = node
          @bin_items = options[:bin_items] || {}
          parse_attributes
        end

        # Get the binary item reference ID
        def bin_item_id
          @bin_item_id ||= begin
            # Look for binItemIDRef in hp:img or hp:imgRect
            img_node = @node.at_xpath(".//hp:img|.//hp:imgRect")
            img_node&.attribute("binItemIDRef")&.value
          end
        end

        # Get the source file path within the HWPX archive
        def source_path
          return nil unless bin_item_id

          bin_info = @bin_items[bin_item_id]
          bin_info&.dig(:path)
        end

        # Get the original filename
        def original_filename
          return nil unless source_path

          File.basename(source_path)
        end

        # Get the file extension
        def extension
          return nil unless original_filename

          File.extname(original_filename).downcase
        end

        # Check if this is a valid image reference
        def valid?
          !bin_item_id.nil? && !source_path.nil?
        end

        # Get the caption/alt text if available
        def caption
          @caption ||= begin
            # Look for caption in hp:caption element
            caption_node = @node.at_xpath(".//hp:caption//hp:t")
            caption_node&.text&.strip
          end
        end

        # Generate markdown image syntax
        #
        # @param image_path [String] Path to the extracted image
        # @return [String] Markdown image syntax
        def to_markdown(image_path)
          alt_text = caption || "image"
          "![#{alt_text}](#{image_path})"
        end

        # Generate HTML img tag
        #
        # @param image_path [String] Path to the extracted image
        # @return [String] HTML img tag
        def to_html(image_path)
          alt_text = caption || "image"
          style = []
          style << "width: #{@width}px" if @width
          style << "height: #{@height}px" if @height
          style_attr = style.empty? ? "" : " style=\"#{style.join("; ")}\""
          "<img src=\"#{image_path}\" alt=\"#{alt_text}\"#{style_attr}>"
        end

        private

        def parse_attributes
          # Parse size from hp:sz element
          sz_node = @node.at_xpath(".//hp:sz")
          if sz_node
            # HWPX uses HWP units (1/7200 inch), convert to approximate pixels
            @width = hwp_to_pixels(sz_node.attribute("width")&.value)
            @height = hwp_to_pixels(sz_node.attribute("height")&.value)
          end
        end

        # Convert HWP units to approximate pixels (72 DPI)
        def hwp_to_pixels(hwp_value)
          return nil unless hwp_value

          # HWP unit: 1/7200 inch, convert to pixels at 72 DPI
          (hwp_value.to_i / 100.0).round
        end
      end
    end
  end
end
