# frozen_string_literal: true

require_relative "test_helper"
require "tempfile"

describe "Hwpx2md::ImageExtractor" do
  describe "with document without images" do
    before do
      @data_folder = File.dirname(File.expand_path(__FILE__)) + "/data"
      @hwpx_path = @data_folder + "/sample1.hwpx"
      skip "sample1.hwpx not found" unless File.exist?(@hwpx_path)
      @doc = Hwpx2md::Document.new(@hwpx_path)
    end

    it "has image_extractor" do
      assert_respond_to @doc, :image_extractor
    end

    it "reports no images" do
      refute @doc.has_images?
    end

    it "reports zero image count" do
      assert_equal 0, @doc.image_count
    end

    it "returns empty hash for extract_images" do
      Dir.mktmpdir do |tmpdir|
        result = @doc.extract_images(tmpdir)
        assert_equal({}, result)
      end
    end
  end

  describe "ImageExtractor class" do
    before do
      # Create a mock XML document with an image reference
      @doc_xml = Nokogiri::XML(<<~XML)
        <hs:sec xmlns:hs="http://www.hancom.co.kr/hwpml/2011/section"
                xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
          <hp:p>
            <hp:pic>
              <hp:img binItemIDRef="BIN0001"/>
            </hp:pic>
          </hp:p>
        </hs:sec>
      XML

      @header_xml = Nokogiri::XML(<<~XML)
        <hh:head xmlns:hh="http://www.hancom.co.kr/hwpml/2011/head">
          <hh:binItem id="BIN0001" src="BinData/BIN0001.png" format="png"/>
        </hh:head>
      XML
    end

    it "finds images in document" do
      # Create mock zip
      mock_zip = Minitest::Mock.new
      mock_zip.expect(:glob, [], ["BinData/*"])

      extractor = Hwpx2md::ImageExtractor.new(mock_zip, @doc_xml, @header_xml)
      assert extractor.has_images?
      assert_equal 1, extractor.count

      mock_zip.verify
    end

    it "builds bin_items from header" do
      mock_zip = Minitest::Mock.new
      mock_zip.expect(:glob, [], ["BinData/*"])

      extractor = Hwpx2md::ImageExtractor.new(mock_zip, @doc_xml, @header_xml)

      bin_items = extractor.bin_items
      assert_includes bin_items.keys, "BIN0001"
      assert_equal "BinData/BIN0001.png", bin_items["BIN0001"][:path]

      mock_zip.verify
    end

    it "generates relative paths" do
      mock_zip = Minitest::Mock.new
      mock_zip.expect(:glob, [], ["BinData/*"])

      extractor = Hwpx2md::ImageExtractor.new(mock_zip, @doc_xml, @header_xml)
      paths = extractor.relative_paths("img")

      assert_includes paths.values.first, "img/"
      assert paths.values.first.end_with?(".png")

      mock_zip.verify
    end
  end

  describe "filename generation" do
    before do
      @doc_xml = Nokogiri::XML(<<~XML)
        <hs:sec xmlns:hs="http://www.hancom.co.kr/hwpml/2011/section"
                xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
          <hp:p>
            <hp:pic>
              <hp:img binItemIDRef="BIN0001"/>
              <hp:caption><hp:t>My Test Image</hp:t></hp:caption>
            </hp:pic>
          </hp:p>
        </hs:sec>
      XML

      @header_xml = Nokogiri::XML(<<~XML)
        <hh:head xmlns:hh="http://www.hancom.co.kr/hwpml/2011/head">
          <hh:binItem id="BIN0001" src="BinData/BIN0001.png" format="png"/>
        </hh:head>
      XML

      mock_zip = Minitest::Mock.new
      mock_zip.expect(:glob, [], ["BinData/*"])

      @extractor = Hwpx2md::ImageExtractor.new(mock_zip, @doc_xml, @header_xml)
    end

    it "generates descriptive filenames with caption" do
      paths = @extractor.relative_paths
      filename = File.basename(paths.values.first)

      # Should include caption (sanitized)
      assert_includes filename, "My_Test_Image"
      assert filename.end_with?(".png")
    end
  end
end
