# frozen_string_literal: true

require_relative "../test_helper"
require "nokogiri"

# Force load containers by referencing Document
Hwpx2md::Document

describe "FootnoteNode class" do
  before do
    data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
    @section_xml_path = data_folder + "/book/Contents/section0.xml"
    skip "section0.xml not found" unless File.exist?(@section_xml_path)

    xml_content = File.read(@section_xml_path)
    @doc = Nokogiri::XML(xml_content)
    @doc.remove_namespaces!
  end

  describe "#initialize" do
    it "creates FootnoteNode from XML node" do
      footnote_nodes = @doc.xpath("//footNote")
      skip "No footnote nodes found in test data" if footnote_nodes.empty?

      footnote_node = Hwpx2md::Elements::Containers::FootnoteNode.new(footnote_nodes.first)
      assert_instance_of Hwpx2md::Elements::Containers::FootnoteNode, footnote_node
    end
  end

  describe "#to_txt" do
    it "returns footnote marker string" do
      footnote_nodes = @doc.xpath("//footNote")
      skip "No footnote nodes found in test data" if footnote_nodes.empty?

      footnote_node = Hwpx2md::Elements::Containers::FootnoteNode.new(footnote_nodes.first)
      result = footnote_node.to_txt

      assert_instance_of String, result
      assert_match(/\[\^\d+\]/, result, "FootnoteNode#to_txt should return footnote marker format")
    end
  end
end

describe "Footnote parsing from XML" do
  before do
    data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
    @section_xml_path = data_folder + "/book/Contents/section0.xml"
    skip "section0.xml not found" unless File.exist?(@section_xml_path)

    xml_content = File.read(@section_xml_path)
    @doc = Nokogiri::XML(xml_content)
    @doc.remove_namespaces!
  end

  describe "footnote structure in XML" do
    it "finds footNote elements in test data" do
      footnote_nodes = @doc.xpath("//footNote")
      refute_empty footnote_nodes, "Test data should contain footNote elements"
    end

    it "finds multiple footnotes" do
      footnote_nodes = @doc.xpath("//footNote")
      assert_operator footnote_nodes.length, :>=, 2, "Test data should contain at least 2 footnotes"
    end

    it "footnotes have number attribute" do
      footnote_nodes = @doc.xpath("//footNote")
      skip "No footnote nodes found" if footnote_nodes.empty?

      first_footnote = footnote_nodes.first
      assert first_footnote["number"], "FootNote should have number attribute"
    end

    it "footnotes contain autoNum element" do
      footnote_nodes = @doc.xpath("//footNote")
      skip "No footnote nodes found" if footnote_nodes.empty?

      auto_num = footnote_nodes.first.at_xpath(".//autoNum")
      refute_nil auto_num, "FootNote should contain autoNum element"
    end

    it "autoNum has num attribute" do
      auto_num = @doc.at_xpath("//footNote//autoNum")
      skip "No autoNum found" unless auto_num

      assert auto_num["num"], "autoNum should have num attribute"
      assert_equal "1", auto_num["num"], "First footnote autoNum should be 1"
    end

    it "footnotes contain text content" do
      footnote_nodes = @doc.xpath("//footNote")
      skip "No footnote nodes found" if footnote_nodes.empty?

      text_node = footnote_nodes.first.at_xpath(".//t")
      refute_nil text_node, "FootNote should contain text element"
      assert_includes text_node.content, "footnote1 text"
    end
  end
end

describe "Paragraph with footnotes" do
  before do
    data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
    @section_xml_path = data_folder + "/book/Contents/section0.xml"
    skip "section0.xml not found" unless File.exist?(@section_xml_path)

    xml_content = File.read(@section_xml_path)
    # Keep namespaces for Paragraph#to_txt which uses hp: prefixed XPath
    @doc = Nokogiri::XML(xml_content)
    # Define the hp namespace for XPath queries
    @ns = { "hp" => "http://www.hancom.co.kr/hwpml/2011/paragraph" }
  end

  describe "paragraph with footnote nodes" do
    it "creates paragraph from XML node containing footnote" do
      # Find a paragraph that contains a footnote using namespace
      para_with_footnote = @doc.xpath("//hp:p[.//hp:footNote]", @ns).first
      skip "No paragraph with footnote found" unless para_with_footnote

      paragraph = Hwpx2md::Elements::Containers::Paragraph.new(para_with_footnote)
      assert_instance_of Hwpx2md::Elements::Containers::Paragraph, paragraph
    end

    it "paragraph responds to paragraph_footnotes" do
      para_with_footnote = @doc.xpath("//hp:p[.//hp:footNote]", @ns).first
      skip "No paragraph with footnote found" unless para_with_footnote

      paragraph = Hwpx2md::Elements::Containers::Paragraph.new(para_with_footnote)
      assert_respond_to paragraph, :paragraph_footnotes
    end

    it "to_txt includes footnote markers" do
      para_with_footnote = @doc.xpath("//hp:p[.//hp:footNote]", @ns).first
      skip "No paragraph with footnote found" unless para_with_footnote

      paragraph = Hwpx2md::Elements::Containers::Paragraph.new(para_with_footnote)
      # Pass nil as document since we're just testing text extraction
      text = paragraph.to_txt(nil)

      assert_includes text, "[^", "Paragraph text should include footnote marker"
    end

    it "to_txt includes footnote definitions" do
      para_with_footnote = @doc.xpath("//hp:p[.//hp:footNote]", @ns).first
      skip "No paragraph with footnote found" unless para_with_footnote

      paragraph = Hwpx2md::Elements::Containers::Paragraph.new(para_with_footnote)
      text = paragraph.to_txt(nil)

      assert_match(/\[\^\d+\]:/, text, "Paragraph text should include footnote definition")
    end

    it "to_txt includes footnote text content" do
      para_with_footnote = @doc.xpath("//hp:p[.//hp:footNote]", @ns).first
      skip "No paragraph with footnote found" unless para_with_footnote

      paragraph = Hwpx2md::Elements::Containers::Paragraph.new(para_with_footnote)
      text = paragraph.to_txt(nil)

      # The first footnote contains "footnote1 text"
      assert_includes text, "footnote1 text", "Paragraph should include footnote text content"
    end
  end

  describe "multiple footnotes in paragraph" do
    it "handles multiple footnotes correctly" do
      # Find paragraph with multiple footnotes
      para_with_multiple = @doc.xpath("//hp:p[count(.//hp:footNote) >= 2]", @ns).first
      skip "No paragraph with multiple footnotes found" unless para_with_multiple

      paragraph = Hwpx2md::Elements::Containers::Paragraph.new(para_with_multiple)
      text = paragraph.to_txt(nil)

      assert_includes text, "[^1]", "Should include first footnote marker"
      assert_includes text, "[^2]", "Should include second footnote marker"
    end

    it "preserves footnote order" do
      para_with_multiple = @doc.xpath("//hp:p[count(.//hp:footNote) >= 2]", @ns).first
      skip "No paragraph with multiple footnotes found" unless para_with_multiple

      paragraph = Hwpx2md::Elements::Containers::Paragraph.new(para_with_multiple)
      text = paragraph.to_txt(nil)

      first_marker_pos = text.index("[^1]")
      second_marker_pos = text.index("[^2]")

      refute_nil first_marker_pos, "First footnote marker should exist"
      refute_nil second_marker_pos, "Second footnote marker should exist"
      assert first_marker_pos < second_marker_pos, "First marker should appear before second"
    end
  end
end
