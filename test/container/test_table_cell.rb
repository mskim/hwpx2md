# frozen_string_literal: true

require_relative "../test_helper"

describe "Hwpx2md::Elements::Containers::TableCell" do
  before do
    # Create a minimal XML node for testing
    @xml = Nokogiri::XML(<<~XML)
      <hp:tc xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
        <hp:cellAddr colAddr="0" rowAddr="0"/>
        <hp:cellSpan colSpan="1" rowSpan="1"/>
        <hp:subList vertAlign="center">
          <hp:p>
            <hp:pPr align="left"/>
            <hp:t>Test cell content</hp:t>
          </hp:p>
        </hp:subList>
      </hp:tc>
    XML
    @cell = Hwpx2md::Elements::Containers::TableCell.new(@xml.root)
  end

  describe "#to_s" do
    it "returns cell text content" do
      assert_equal "Test cell content", @cell.to_s
    end
  end

  describe "#text" do
    it "is an alias for to_s" do
      assert_equal @cell.to_s, @cell.text
    end
  end

  describe "#position" do
    it "returns column and row position" do
      col, row = @cell.position
      assert_equal 0, col
      assert_equal 0, row
    end

    it "returns [0, 0] when no address node exists" do
      xml = Nokogiri::XML('<hp:tc xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph"><hp:t>Text</hp:t></hp:tc>')
      cell = Hwpx2md::Elements::Containers::TableCell.new(xml.root)
      assert_equal [0, 0], cell.position
    end
  end

  describe "#spans" do
    it "returns column and row span values" do
      col_span, row_span = @cell.spans
      assert_equal 1, col_span
      assert_equal 1, row_span
    end

    it "returns [1, 1] when no span node exists" do
      xml = Nokogiri::XML('<hp:tc xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph"><hp:t>Text</hp:t></hp:tc>')
      cell = Hwpx2md::Elements::Containers::TableCell.new(xml.root)
      assert_equal [1, 1], cell.spans
    end
  end

  describe "#merged?" do
    it "returns false for non-merged cell" do
      refute @cell.merged?
    end

    it "returns true for merged cell with colspan > 1" do
      xml = Nokogiri::XML(<<~XML)
        <hp:tc xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
          <hp:cellSpan colSpan="2" rowSpan="1"/>
          <hp:t>Merged</hp:t>
        </hp:tc>
      XML
      cell = Hwpx2md::Elements::Containers::TableCell.new(xml.root)
      assert cell.merged?
    end

    it "returns true for merged cell with rowspan > 1" do
      xml = Nokogiri::XML(<<~XML)
        <hp:tc xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
          <hp:cellSpan colSpan="1" rowSpan="2"/>
          <hp:t>Merged</hp:t>
        </hp:tc>
      XML
      cell = Hwpx2md::Elements::Containers::TableCell.new(xml.root)
      assert cell.merged?
    end
  end

  describe "#to_markdown" do
    it "returns trimmed text content" do
      assert_equal "Test cell content", @cell.to_markdown
    end

    it "escapes pipe characters" do
      xml = Nokogiri::XML('<hp:tc xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph"><hp:t>Value | With | Pipes</hp:t></hp:tc>')
      cell = Hwpx2md::Elements::Containers::TableCell.new(xml.root)
      assert_equal 'Value \\| With \\| Pipes', cell.to_markdown
    end

    it "returns non-breaking space for empty cells" do
      xml = Nokogiri::XML('<hp:tc xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph"><hp:t></hp:t></hp:tc>')
      cell = Hwpx2md::Elements::Containers::TableCell.new(xml.root)
      assert_equal "&nbsp;", cell.to_markdown
    end

    it "returns non-breaking space for whitespace-only cells" do
      xml = Nokogiri::XML('<hp:tc xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph"><hp:t>   </hp:t></hp:tc>')
      cell = Hwpx2md::Elements::Containers::TableCell.new(xml.root)
      assert_equal "&nbsp;", cell.to_markdown
    end
  end

  describe "#horizontal_align" do
    it "returns left as default" do
      xml = Nokogiri::XML('<hp:tc xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph"><hp:t>Text</hp:t></hp:tc>')
      cell = Hwpx2md::Elements::Containers::TableCell.new(xml.root)
      assert_equal "left", cell.horizontal_align
    end
  end

  describe "#vertical_align" do
    it "returns center as default" do
      xml = Nokogiri::XML('<hp:tc xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph"><hp:t>Text</hp:t></hp:tc>')
      cell = Hwpx2md::Elements::Containers::TableCell.new(xml.root)
      assert_equal "center", cell.vertical_align
    end
  end
end
