# frozen_string_literal: true

require_relative "../test_helper"

describe "Hwpx2md::Elements::Containers::Table" do
  before do
    @xml = Nokogiri::XML(<<~XML)
      <hp:tbl xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
        <hp:tblGrid>
          <hp:gridCol/>
          <hp:gridCol/>
          <hp:gridCol/>
        </hp:tblGrid>
        <hp:tr>
          <hp:tc><hp:t>H1</hp:t></hp:tc>
          <hp:tc><hp:t>H2</hp:t></hp:tc>
          <hp:tc><hp:t>H3</hp:t></hp:tc>
        </hp:tr>
        <hp:tr>
          <hp:tc><hp:t>A1</hp:t></hp:tc>
          <hp:tc><hp:t>A2</hp:t></hp:tc>
          <hp:tc><hp:t>A3</hp:t></hp:tc>
        </hp:tr>
        <hp:tr>
          <hp:tc><hp:t>B1</hp:t></hp:tc>
          <hp:tc><hp:t>B2</hp:t></hp:tc>
          <hp:tc><hp:t>B3</hp:t></hp:tc>
        </hp:tr>
      </hp:tbl>
    XML
    @table = Hwpx2md::Elements::Containers::Table.new(@xml.root)
  end

  describe "#rows" do
    it "returns an array of TableRow objects" do
      rows = @table.rows
      assert_instance_of Array, rows
      assert_equal 3, rows.length
      rows.each do |row|
        assert_instance_of Hwpx2md::Elements::Containers::TableRow, row
      end
    end
  end

  describe "#row_count" do
    it "returns correct number of rows" do
      assert_equal 3, @table.row_count
    end
  end

  describe "#column_count" do
    it "returns correct number of columns" do
      assert_equal 3, @table.column_count
    end
  end

  describe "#columns" do
    it "returns an array of TableColumn objects" do
      columns = @table.columns
      assert_instance_of Array, columns
      assert_equal 3, columns.length
    end
  end

  describe "#to_markdown" do
    it "returns a valid markdown table" do
      markdown = @table.to_markdown

      # Check header row
      assert_includes markdown, "| H1 | H2 | H3 |"

      # Check separator row
      assert_includes markdown, "|:---|:---|:---|"

      # Check data rows
      assert_includes markdown, "| A1 | A2 | A3 |"
      assert_includes markdown, "| B1 | B2 | B3 |"
    end

    it "includes newlines for formatting" do
      markdown = @table.to_markdown
      assert markdown.start_with?("\n")
      assert markdown.end_with?("\n\n")
    end
  end

  describe "#to_txt" do
    it "is an alias for to_markdown" do
      assert_equal @table.to_markdown, @table.to_txt
    end
  end

  describe "#each_rows" do
    it "yields each row" do
      count = 0
      @table.each_rows { |row| count += 1 }
      assert_equal 3, count
    end
  end

  describe "empty table" do
    before do
      @empty_xml = Nokogiri::XML(<<~XML)
        <hp:tbl xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
          <hp:tblGrid></hp:tblGrid>
        </hp:tbl>
      XML
      @empty_table = Hwpx2md::Elements::Containers::Table.new(@empty_xml.root)
    end

    it "returns empty string for markdown" do
      assert_equal "", @empty_table.to_markdown
    end

    it "returns 0 for row_count" do
      assert_equal 0, @empty_table.row_count
    end

    it "returns 0 for column_count" do
      assert_equal 0, @empty_table.column_count
    end
  end

  describe "#alignment_separator" do
    it "returns left-aligned separators by default" do
      separator = @table.alignment_separator
      assert_includes separator, ":---"
    end
  end

  describe "#has_header?" do
    it "returns false by default" do
      refute @table.has_header?
    end

    it "returns true when repeatHeader is set" do
      xml = Nokogiri::XML(<<~XML)
        <hp:tbl repeatHeader="1" xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
          <hp:tblGrid><hp:gridCol/></hp:tblGrid>
          <hp:tr><hp:tc><hp:t>H</hp:t></hp:tc></hp:tr>
        </hp:tbl>
      XML
      table = Hwpx2md::Elements::Containers::Table.new(xml.root)
      assert table.has_header?
    end
  end
end
