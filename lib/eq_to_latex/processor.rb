# frozen_string_literal: true

module EqToLatex
  # Pre and post processing for equation strings
  class Processor
    # HTML entity mappings
    HTML_ENTITIES = {
      "&lt;" => "<",
      "&gt;" => ">"
    }.freeze

    # Pre-process equation string before conversion
    #
    # @param script [String] Raw equation string
    # @return [String] Cleaned equation string
    def pre_process(script)
      script = remove_jokbo_watermark(script)
      script = normalize_whitespace(script)
      script = convert_backslash_to_roman(script)
      script = decode_html_entities(script)
      script = convert_subscript_superscript(script)
      script
    end

    # Post-process equation string after conversion
    #
    # @param script [String] Converted equation string
    # @return [String] Final cleaned equation string
    def post_process(script)
      normalize_whitespace(script)
    end

    private

    # Remove Jokbo.com watermark text (Korean education site)
    def remove_jokbo_watermark(script)
      script.gsub(/from\s*=+\s*(?:족보닷컴[\s\S]*?)=+/, "")
    end

    # Collapse multiple whitespace to single space
    def normalize_whitespace(script)
      script.gsub(/\s+/, " ").strip
    end

    # Convert backslash prefix to Roman font command
    # In Hangul equations, \ prefix means Roman (non-italic) text
    def convert_backslash_to_roman(script)
      script.gsub(/^\\| \\/, " \\rm ")
    end

    # Decode HTML entities to actual characters
    def decode_html_entities(script)
      HTML_ENTITIES.reduce(script) do |s, (entity, char)|
        s.gsub(entity, char)
      end
    end

    # Convert _ and ^ to sub/sup commands
    # Hangul equations use these as shortcuts
    def convert_subscript_superscript(script)
      script
        .gsub("_", " sub ")
        .gsub("^", " sup ")
    end
  end
end
