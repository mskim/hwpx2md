# frozen_string_literal: true

require_relative "../test_helper"

describe "Hwpx2md::Elements::Containers::TableRow" do
  before do
    @xml = Nokogiri::XML(<<~XML)
      <hp:tr xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
        <hp:tc>
          <hp:cellAddr colAddr="0" rowAddr="0"/>
          <hp:t>Cell 1</hp:t>
        </hp:tc>
        <hp:tc>
          <hp:cellAddr colAddr="1" rowAddr="0"/>
          <hp:t>Cell 2</hp:t>
        </hp:tc>
        <hp:tc>
          <hp:cellAddr colAddr="2" rowAddr="0"/>
          <hp:t>Cell 3</hp:t>
        </hp:tc>
      </hp:tr>
    XML
    @row = Hwpx2md::Elements::Containers::TableRow.new(@xml.root)
  end

  describe "#cells" do
    it "returns an array of TableCell objects" do
      cells = @row.cells
      assert_instance_of Array, cells
      assert_equal 3, cells.length
      cells.each do |cell|
        assert_instance_of Hwpx2md::Elements::Containers::TableCell, cell
      end
    end

    it "returns cells in order" do
      cells = @row.cells
      assert_equal "Cell 1", cells[0].text
      assert_equal "Cell 2", cells[1].text
      assert_equal "Cell 3", cells[2].text
    end
  end

  describe "#to_markdown" do
    it "returns cells formatted as markdown table row" do
      expected = "| Cell 1 | Cell 2 | Cell 3 |"
      assert_equal expected, @row.to_markdown
    end
  end

  describe "#to_txt" do
    it "is an alias for to_markdown" do
      assert_equal @row.to_markdown, @row.to_txt
    end
  end

  describe "with empty row" do
    before do
      @empty_xml = Nokogiri::XML('<hp:tr xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph"></hp:tr>')
      @empty_row = Hwpx2md::Elements::Containers::TableRow.new(@empty_xml.root)
    end

    it "returns empty cells array" do
      assert_equal [], @empty_row.cells
    end

    it "returns minimal markdown row" do
      assert_equal "|  |", @empty_row.to_markdown
    end
  end

  describe "with special characters" do
    before do
      @special_xml = Nokogiri::XML(<<~XML)
        <hp:tr xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
          <hp:tc><hp:t>Normal</hp:t></hp:tc>
          <hp:tc><hp:t>With | Pipe</hp:t></hp:tc>
        </hp:tr>
      XML
      @special_row = Hwpx2md::Elements::Containers::TableRow.new(@special_xml.root)
    end

    it "escapes pipe characters in cells" do
      markdown = @special_row.to_markdown
      assert_includes markdown, 'With \\| Pipe'
    end
  end
end
