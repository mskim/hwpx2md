require "hwpx2md/containers/text_run"
require "hwpx2md/containers/container"

# ^<\?xml (.|\n)*?</hp:secPr> -> delete
# <hp:footNote number="([0-9]*)" (.|\n)*?<hp:autoNum num="([0-9]*)" (.|\n)*?<hp:t>((.)*?)</hp:t>(.|\n)*?</hp:footNote>    -> [^$1] "[^$3]$5" # 주석처리
# <[/]?hp:ctrl> -> delete
# <[/]?hp:run>  -> delete
# <hp:run (.)*?"[/]?>  -> delete
# <[/]?hp:p>  -> delete
# <hp:p (.)*?"[/]?>  -> delete
# <hp:colPr (.)*?"[/]?> -> delete
# </hs:sec>  -> delete
# <hp:pageNum (.)*?"[/]?>  -> delete

# <hp:linesegarray>(.|\n)*?</hp:linesegarray> -> \n
# <hp:lineBreak/>  -> \n

# <[/]?hp:t>  -> delete

module Hwpx2md
  module Elements
    module Containers
      # Paragraph of Document
      RUNS_PATTERNS = //
      LINE_SEG_ARRAY = //
      CONTROLS_PATTERNS = //

      class Paragraph
        include Container
        include Elements::Element
        attr_reader :paragraph_footnotes, :footnote_number, :text_with_footnote

        # Child elements: pPr, r, fldSimple, hlink, subDoc
        # http://msdn.microsoft.com/en-us/library/office/ee364458(v=office.11).aspx
        def initialize(node, document_properties = {})
          @node = node
          @properties_tag = "pPr"
          @document_properties = document_properties
          @font_size = @document_properties[:font_size]
          @paragraph_footnotes = []
        end

        def self.tag
          "p"
        end

        # Array of text runs contained within paragraph
        def text_runs
          runs = @node.xpath(".//hp:run")
          runs.map do |r|
            text_nodes = r.xpath(".//hp:t|.//hp:ctrl//hp:footNote")
            text_nodes.each do |t_node|
              if t_node.name == "t"
                Containers::TextRun.new(t_node, @document_properties)
              elsif t_node.name == "footNote"
                Containers::FootnoteNode.new(t_node, @document_properties)
              elsif t_node.name == "script"
                Containers::MathNode.new(t_node, @document_properties)
              end
            end
          end
        end

        def eq2latex(eq_string)
          latex = EqToLatex::Converter.new.convert(eq_string)
        end

        def to_txt(_document)
          @para_footnote_numbers = []
          @para_footnotes = []
          @para_text = ""
          para_nodes = @node.xpath(".//hp:run|.//hp:linesegarray")
          para_nodes.each do |para_run|
            if para_run.path =~ /hp:run/
              run_nodes = para_run.xpath(".//hp:ctrl|.//hp:t|.//hp:script")
              run_nodes.each do |run_node|
                if run_node.path =~ /hp:ctrl/
                  ctrl_node = run_node
                  ctrl_children = run_node.xpath(".//hp:footNote|.//hp:t")
                  ctrl_children.each do |ctrl_child|
                    if ctrl_child.path =~ /hp:footNote/
                      auto_num_node = ctrl_node.at_xpath(".//hp:autoNum")
                      next unless auto_num_node
                      auto_num_node_path = auto_num_node.path
                      footnote_number = auto_num_node.attributes["num"].value
                      unless @para_footnote_numbers.include?(footnote_number)
                        @para_text.chomp!
                        @para_text += "[^#{footnote_number}]"
                        @para_footnote_numbers << footnote_number
                      end
                      footnote_text_node = ctrl_node.at_xpath(".//hp:t")
                      footnote_info = []
                      node_path = footnote_text_node.path
                      footnote_info << node_path
                      footnote_info << footnote_number
                      footnote_info << footnote_text_node.content
                      para_footnote_nodes_path =
                        @para_footnotes.map { |e| e[0] }
                      unless para_footnote_nodes_path.include?(node_path)
                        @para_footnotes << footnote_info
                      end
                    else
                      # this is special characters
                      # binding.pry
                    end
                  end
                # elsif run_node.path =~ /hp:t/
                elsif run_node.name == 't'
                  @para_text += run_node.content
                elsif run_node.name == 'script'
                  latex = eq2latex(run_node.content)
                  @para_text += "#{latex}"
                end
              end
            elsif para_run.path =~ /hp:linesegarray/
              @para_text += "\n"
            end
          end
          @para_footnotes.each_with_index do |footnote, i|
            @para_text += "\n" if i == 0
            @para_text += "[^#{footnote[1]}]:#{footnote[2]}\n"
            @para_text += "\n"
          end
          @para_text.gsub!("**\n", "**")
          @para_text.gsub!("\n!**", "!**")
          @para_text
        end

        # Return text of paragraph
        def to_s
          text_runs.map(&:text).join("")
        end

        # Iterate over each text run within a paragraph
        def each_text_run(&block)
          text_runs.each(&block)
        end

        def aligned_left?
          ["left", nil].include?(alignment)
        end

        def aligned_right?
          alignment == "right"
        end

        def aligned_center?
          alignment == "center"
        end

        def font_size
          size_tag = @node.xpath("w:pPr//w:sz").first
          size_tag ? size_tag.attributes["val"].value.to_i / 2 : @font_size
        end

        alias text to_s

        private

        # Returns the alignment if any, or nil if left
        def alignment
          alignment_tag = @node.xpath(".//w:jc").first
          alignment_tag ? alignment_tag.attributes["val"].value : nil
        end
      end
    end
  end
end
