# frozen_string_literal: true

require "fileutils"

module Hwpx2md
  # Handles extraction and management of images from HWPX documents
  class ImageExtractor
    attr_reader :images, :bin_items

    # Initialize extractor with zip file and parsed document
    #
    # @param zip [Zip::File] The HWPX zip file
    # @param doc [Nokogiri::XML::Document] The parsed section XML
    # @param header_doc [Nokogiri::XML::Document] The parsed header XML
    def initialize(zip, doc, header_doc = nil)
      @zip = zip
      @doc = doc
      @header_doc = header_doc
      @bin_items = {}
      @images = []
      @image_counter = 0
      @page_counter = 1

      parse_bin_items if @header_doc
      find_images
    end

    # Check if document has any images
    def has_images?
      @images.any?
    end

    # Get count of images
    def count
      @images.size
    end

    # Extract all images to specified directory
    #
    # @param output_dir [String] Directory to save images
    # @param naming [Symbol] Naming convention (:sequential, :original, :descriptive)
    # @return [Hash] Map of bin_item_id to extracted file path
    def extract_to(output_dir, naming: :descriptive)
      return {} unless has_images?

      FileUtils.mkdir_p(output_dir)
      extracted = {}

      @images.each_with_index do |image_node, index|
        next unless image_node.valid?

        source_path = image_node.source_path
        next unless source_path

        entry = @zip.find_entry(source_path)
        next unless entry

        filename = generate_filename(image_node, index, naming)
        output_path = File.join(output_dir, filename)

        # Extract the image
        entry.extract(output_path) { true } # Overwrite if exists

        extracted[image_node.bin_item_id] = output_path
      end

      extracted
    end

    # Get relative paths for markdown/HTML output
    #
    # @param images_dir [String] Name of images directory (e.g., "images")
    # @return [Hash] Map of bin_item_id to relative path
    def relative_paths(images_dir = "images")
      paths = {}
      @images.each_with_index do |image_node, index|
        next unless image_node.valid?

        filename = generate_filename(image_node, index, :descriptive)
        paths[image_node.bin_item_id] = File.join(images_dir, filename)
      end
      paths
    end

    private

    # Parse binary items from header.xml
    # Maps binItemIDRef to file paths in BinData/
    def parse_bin_items
      # Look for hh:binItem elements in header
      @header_doc.xpath("//hh:binItem").each do |item|
        id = item.attribute("id")&.value
        next unless id

        # Get the file path from the item
        # Format varies: could be direct path or itemIDRef
        path = item.attribute("src")&.value
        path ||= "BinData/#{item.attribute("id")&.value}"

        # Determine type from format attribute
        format = item.attribute("format")&.value&.downcase || guess_format(path)

        @bin_items[id] = {
          path: path,
          format: format
        }
      end

      # Also check for direct BinData references
      @zip.glob("BinData/*").each do |entry|
        # Create entries for files we find directly
        basename = File.basename(entry.name, ".*")
        unless @bin_items.key?(basename)
          @bin_items[basename] = {
            path: entry.name,
            format: File.extname(entry.name).downcase.delete(".")
          }
        end
      end
    end

    # Find all image references in the document
    def find_images
      @doc.xpath("//hp:pic").each do |pic_node|
        image_node = Elements::Containers::ImageNode.new(pic_node, bin_items: @bin_items)
        @images << image_node if image_node.bin_item_id
      end
    end

    # Generate filename based on naming convention
    #
    # @param image_node [ImageNode] The image node
    # @param index [Integer] Sequential index
    # @param naming [Symbol] Naming convention
    # @return [String] Generated filename
    def generate_filename(image_node, index, naming)
      ext = image_node.extension || ".png"
      ext = ".#{ext}" unless ext.start_with?(".")

      case naming
      when :original
        image_node.original_filename || "image_#{index + 1}#{ext}"
      when :sequential
        "image_#{format("%03d", index + 1)}#{ext}"
      when :descriptive
        # Format: {page}_{order}_{caption}.ext
        page = @page_counter
        order = index + 1
        caption = sanitize_filename(image_node.caption || "image")
        caption = caption[0, 30] if caption.length > 30 # Limit caption length
        "#{page}_#{order}_#{caption}#{ext}"
      else
        "image_#{index + 1}#{ext}"
      end
    end

    # Sanitize string for use in filename
    def sanitize_filename(name)
      # Replace invalid filename characters and spaces
      # Using %r{} to avoid escaping issues with special characters
      name.gsub(%r{[<>:"/\\|?*\s]}, "_").gsub(/_+/, "_").strip
    end

    # Guess format from file path
    def guess_format(path)
      return nil unless path

      ext = File.extname(path).downcase.delete(".")
      case ext
      when "jpg", "jpeg" then "jpg"
      when "png" then "png"
      when "gif" then "gif"
      when "bmp" then "bmp"
      when "tiff", "tif" then "tiff"
      else ext
      end
    end
  end
end
