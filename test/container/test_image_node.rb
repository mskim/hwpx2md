# frozen_string_literal: true

require_relative "../test_helper"

describe "Hwpx2md::Elements::Containers::ImageNode" do
  before do
    @bin_items = {
      "BIN0001" => { path: "BinData/BIN0001.png", format: "png" },
      "BIN0002" => { path: "BinData/BIN0002.jpg", format: "jpg" }
    }
  end

  describe "with valid image reference" do
    before do
      @xml = Nokogiri::XML(<<~XML)
        <hp:pic xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
          <hp:img binItemIDRef="BIN0001"/>
          <hp:sz width="10000" height="8000"/>
          <hp:caption><hp:t>Test Caption</hp:t></hp:caption>
        </hp:pic>
      XML
      @image = Hwpx2md::Elements::Containers::ImageNode.new(@xml.root, bin_items: @bin_items)
    end

    it "returns correct bin_item_id" do
      assert_equal "BIN0001", @image.bin_item_id
    end

    it "returns correct source_path" do
      assert_equal "BinData/BIN0001.png", @image.source_path
    end

    it "returns correct original_filename" do
      assert_equal "BIN0001.png", @image.original_filename
    end

    it "returns correct extension" do
      assert_equal ".png", @image.extension
    end

    it "is valid" do
      assert @image.valid?
    end

    it "returns caption text" do
      assert_equal "Test Caption", @image.caption
    end

    it "generates markdown with path" do
      markdown = @image.to_markdown("images/test.png")
      assert_equal "![Test Caption](images/test.png)", markdown
    end

    it "generates HTML with path" do
      html = @image.to_html("images/test.png")
      assert_includes html, '<img src="images/test.png"'
      assert_includes html, 'alt="Test Caption"'
    end

    it "includes dimensions in HTML" do
      html = @image.to_html("images/test.png")
      assert_includes html, "width:"
      assert_includes html, "height:"
    end
  end

  describe "with imgRect reference" do
    before do
      @xml = Nokogiri::XML(<<~XML)
        <hp:pic xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
          <hp:imgRect binItemIDRef="BIN0002"/>
        </hp:pic>
      XML
      @image = Hwpx2md::Elements::Containers::ImageNode.new(@xml.root, bin_items: @bin_items)
    end

    it "returns correct bin_item_id from imgRect" do
      assert_equal "BIN0002", @image.bin_item_id
    end

    it "returns correct extension for jpg" do
      assert_equal ".jpg", @image.extension
    end
  end

  describe "without caption" do
    before do
      @xml = Nokogiri::XML(<<~XML)
        <hp:pic xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
          <hp:img binItemIDRef="BIN0001"/>
        </hp:pic>
      XML
      @image = Hwpx2md::Elements::Containers::ImageNode.new(@xml.root, bin_items: @bin_items)
    end

    it "returns nil for caption" do
      assert_nil @image.caption
    end

    it "uses 'image' as default alt text in markdown" do
      markdown = @image.to_markdown("test.png")
      assert_equal "![image](test.png)", markdown
    end
  end

  describe "without bin_items reference" do
    before do
      @xml = Nokogiri::XML(<<~XML)
        <hp:pic xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
          <hp:img binItemIDRef="BIN9999"/>
        </hp:pic>
      XML
      @image = Hwpx2md::Elements::Containers::ImageNode.new(@xml.root, bin_items: @bin_items)
    end

    it "returns bin_item_id even without matching entry" do
      assert_equal "BIN9999", @image.bin_item_id
    end

    it "returns nil for source_path" do
      assert_nil @image.source_path
    end

    it "is not valid" do
      refute @image.valid?
    end
  end

  describe "empty pic node" do
    before do
      @xml = Nokogiri::XML(<<~XML)
        <hp:pic xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
        </hp:pic>
      XML
      @image = Hwpx2md::Elements::Containers::ImageNode.new(@xml.root, bin_items: @bin_items)
    end

    it "returns nil for bin_item_id" do
      assert_nil @image.bin_item_id
    end

    it "is not valid" do
      refute @image.valid?
    end
  end
end
