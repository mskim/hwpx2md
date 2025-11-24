# frozen_string_literal: true

require "fileutils"
require "yaml"

module Hwpx2md
  # Extracts and manages style information from HWPX documents
  class StyleExtractor
    # HWP unit conversion: 1 HWPUNIT = 1/7200 inch
    HWPUNIT_PER_INCH = 7200
    HWPUNIT_PER_MM = HWPUNIT_PER_INCH / 25.4

    attr_reader :document_properties, :paragraph_styles, :character_styles, :fonts

    def initialize(header_doc, section_doc)
      @header_doc = header_doc
      @section_doc = section_doc
      @document_properties = {}
      @paragraph_styles = []
      @character_styles = []
      @fonts = {}

      parse_all if @header_doc && @section_doc
    end

    # Export all styles to YAML files in specified directory
    #
    # @param output_dir [String] Directory to save style files
    # @return [Array<String>] List of created files
    def save_to(output_dir)
      FileUtils.mkdir_p(output_dir)
      files = []

      # Document properties (page size, margins, columns, etc.)
      doc_path = File.join(output_dir, "document_properties.yml")
      File.write(doc_path, @document_properties.to_yaml, encoding: "UTF-8")
      files << doc_path

      # Paragraph styles
      para_path = File.join(output_dir, "paragraph_styles.yml")
      File.write(para_path, @paragraph_styles.to_yaml, encoding: "UTF-8")
      files << para_path

      # Character styles
      char_path = File.join(output_dir, "character_styles.yml")
      File.write(char_path, @character_styles.to_yaml, encoding: "UTF-8")
      files << char_path

      # Font definitions
      font_path = File.join(output_dir, "fonts.yml")
      File.write(font_path, @fonts.to_yaml, encoding: "UTF-8")
      files << font_path

      files
    end

    # Get all styles as a single hash
    def to_hash
      {
        document: @document_properties,
        paragraph_styles: @paragraph_styles,
        character_styles: @character_styles,
        fonts: @fonts
      }
    end

    # Get all styles as YAML string
    def to_yaml
      to_hash.to_yaml
    end

    private

    def parse_all
      parse_document_properties
      parse_fonts
      parse_paragraph_styles
      parse_character_styles
    end

    # Parse document-level properties from section XML
    def parse_document_properties
      sec_pr = @section_doc.at_xpath("//hp:secPr")
      return unless sec_pr

      # Page properties
      page_pr = sec_pr.at_xpath(".//hp:pagePr")
      if page_pr
        @document_properties[:page] = {
          width_hwp: page_pr.attribute("width")&.value&.to_i,
          height_hwp: page_pr.attribute("height")&.value&.to_i,
          width_mm: hwp_to_mm(page_pr.attribute("width")&.value),
          height_mm: hwp_to_mm(page_pr.attribute("height")&.value),
          landscape: page_pr.attribute("landscape")&.value,
          gutter_type: page_pr.attribute("gutterType")&.value
        }

        # Margins
        margin = page_pr.at_xpath(".//hp:margin")
        if margin
          @document_properties[:margins] = {
            left_hwp: margin.attribute("left")&.value&.to_i,
            right_hwp: margin.attribute("right")&.value&.to_i,
            top_hwp: margin.attribute("top")&.value&.to_i,
            bottom_hwp: margin.attribute("bottom")&.value&.to_i,
            header_hwp: margin.attribute("header")&.value&.to_i,
            footer_hwp: margin.attribute("footer")&.value&.to_i,
            gutter_hwp: margin.attribute("gutter")&.value&.to_i,
            left_mm: hwp_to_mm(margin.attribute("left")&.value),
            right_mm: hwp_to_mm(margin.attribute("right")&.value),
            top_mm: hwp_to_mm(margin.attribute("top")&.value),
            bottom_mm: hwp_to_mm(margin.attribute("bottom")&.value),
            header_mm: hwp_to_mm(margin.attribute("header")&.value),
            footer_mm: hwp_to_mm(margin.attribute("footer")&.value),
            gutter_mm: hwp_to_mm(margin.attribute("gutter")&.value)
          }
        end
      end

      # Section properties
      @document_properties[:section] = {
        text_direction: sec_pr.attribute("textDirection")&.value,
        space_columns_hwp: sec_pr.attribute("spaceColumns")&.value&.to_i,
        space_columns_mm: hwp_to_mm(sec_pr.attribute("spaceColumns")&.value),
        tab_stop_hwp: sec_pr.attribute("tabStop")&.value&.to_i,
        tab_stop_mm: hwp_to_mm(sec_pr.attribute("tabStop")&.value)
      }

      # Column properties
      col_pr = @section_doc.at_xpath("//hp:colPr")
      if col_pr
        @document_properties[:columns] = {
          count: col_pr.attribute("colCount")&.value&.to_i || 1,
          type: col_pr.attribute("type")&.value,
          layout: col_pr.attribute("layout")&.value,
          same_size: col_pr.attribute("sameSz")&.value == "1",
          same_gap: col_pr.attribute("sameGap")&.value == "1"
        }
      end

      # Grid settings
      grid = sec_pr.at_xpath(".//hp:grid")
      if grid
        @document_properties[:grid] = {
          line_grid: grid.attribute("lineGrid")&.value&.to_i,
          char_grid: grid.attribute("charGrid")&.value&.to_i
        }
      end
    end

    # Parse font definitions
    def parse_fonts
      @header_doc.xpath("//hh:fontface").each do |fontface|
        lang = fontface.attribute("lang")&.value
        next unless lang

        fonts_for_lang = []
        fontface.xpath(".//hh:font").each do |font|
          fonts_for_lang << {
            id: font.attribute("id")&.value&.to_i,
            face: font.attribute("face")&.value,
            type: font.attribute("type")&.value,
            embedded: font.attribute("isEmbedded")&.value == "1"
          }
        end
        @fonts[lang.downcase.to_sym] = fonts_for_lang
      end
    end

    # Parse paragraph styles from header
    def parse_paragraph_styles
      # First parse paragraph properties
      para_props = {}
      @header_doc.xpath("//hh:paraPr").each do |pr|
        id = pr.attribute("id")&.value&.to_i
        next unless id

        align = pr.at_xpath(".//hh:align")
        line_spacing = pr.at_xpath(".//hh:lineSpacing")
        margin = pr.at_xpath(".//hh:margin//hc:left|.//hh:margin/hc:left")

        para_props[id] = {
          horizontal_align: align&.attribute("horizontal")&.value,
          vertical_align: align&.attribute("vertical")&.value,
          line_spacing_type: line_spacing&.attribute("type")&.value,
          line_spacing_value: line_spacing&.attribute("value")&.value&.to_i,
          tab_pr_id: pr.attribute("tabPrIDRef")&.value&.to_i
        }
      end

      # Then parse named styles
      @header_doc.xpath("//hh:style[@type='PARA']").each do |style|
        id = style.attribute("id")&.value&.to_i
        para_pr_id = style.attribute("paraPrIDRef")&.value&.to_i
        char_pr_id = style.attribute("charPrIDRef")&.value&.to_i

        style_data = {
          id: id,
          name: style.attribute("name")&.value,
          english_name: style.attribute("engName")&.value,
          para_pr_id: para_pr_id,
          char_pr_id: char_pr_id,
          next_style_id: style.attribute("nextStyleIDRef")&.value&.to_i,
          language_id: style.attribute("langID")&.value&.to_i
        }

        # Merge paragraph properties if available
        if para_props[para_pr_id]
          style_data[:properties] = para_props[para_pr_id]
        end

        @paragraph_styles << style_data
      end
    end

    # Parse character styles from header
    def parse_character_styles
      # First parse character properties
      char_props = {}
      @header_doc.xpath("//hh:charPr").each do |pr|
        id = pr.attribute("id")&.value&.to_i
        next unless id

        char_props[id] = {
          height: pr.attribute("height")&.value&.to_i,
          height_pt: hwp_height_to_pt(pr.attribute("height")&.value),
          text_color: pr.attribute("textColor")&.value,
          shade_color: pr.attribute("shadeColor")&.value,
          use_kerning: pr.attribute("useKerning")&.value == "1"
        }

        # Underline
        underline = pr.at_xpath(".//hh:underline")
        if underline
          char_props[id][:underline] = {
            type: underline.attribute("type")&.value,
            shape: underline.attribute("shape")&.value,
            color: underline.attribute("color")&.value
          }
        end

        # Strikeout
        strikeout = pr.at_xpath(".//hh:strikeout")
        if strikeout
          char_props[id][:strikeout] = {
            shape: strikeout.attribute("shape")&.value,
            color: strikeout.attribute("color")&.value
          }
        end
      end

      # Character styles (type='CHAR')
      @header_doc.xpath("//hh:style[@type='CHAR']").each do |style|
        id = style.attribute("id")&.value&.to_i
        char_pr_id = style.attribute("charPrIDRef")&.value&.to_i

        style_data = {
          id: id,
          name: style.attribute("name")&.value,
          english_name: style.attribute("engName")&.value,
          char_pr_id: char_pr_id
        }

        # Merge character properties if available
        if char_props[char_pr_id]
          style_data[:properties] = char_props[char_pr_id]
        end

        @character_styles << style_data
      end

      # Also store raw character properties for reference
      @character_styles << { raw_properties: char_props } unless char_props.empty?
    end

    # Convert HWP units to millimeters
    def hwp_to_mm(value)
      return nil unless value

      (value.to_i / HWPUNIT_PER_MM).round(2)
    end

    # Convert HWP height units to points (font size)
    # HWP uses 1/10 point for font sizes
    def hwp_height_to_pt(value)
      return nil unless value

      (value.to_i / 100.0).round(1)
    end
  end
end
