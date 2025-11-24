# frozen_string_literal: true

require_relative "../test_helper"
require "stringio"

describe "Hwpx2md::Document edge cases" do
  describe "with valid sample files" do
    before do
      @data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
    end

    describe "sample1.hwpx" do
      before do
        @hwpx_path = @data_folder + "/sample1.hwpx"
        skip "sample1.hwpx not found" unless File.exist?(@hwpx_path)
        @doc = Hwpx2md::Document.new(@hwpx_path)
      end

      it "creates a Document instance" do
        assert_instance_of Hwpx2md::Document, @doc
      end

      it "returns paragraphs as an array" do
        assert_instance_of Array, @doc.paragraphs
      end

      it "returns string from to_s" do
        assert_instance_of String, @doc.to_s
      end

      it "returns string from to_txt" do
        assert_instance_of String, @doc.to_txt
      end

      it "to_markdown is alias for to_txt" do
        assert_equal @doc.to_txt, @doc.to_markdown
      end
    end

    describe "sample_table.hwpx" do
      before do
        @hwpx_path = File.join(File.dirname(__FILE__), "..", "sample_table.hwpx")
        skip "sample_table.hwpx not found" unless File.exist?(@hwpx_path)
        @doc = Hwpx2md::Document.new(@hwpx_path)
      end

      it "extracts tables" do
        tables = @doc.tables
        assert_instance_of Array, tables
      end

      it "converts tables to markdown format" do
        markdown = @doc.to_markdown
        # Should have pipe characters for table formatting
        assert_includes markdown, "|"
      end
    end

    describe "sample_math.hwpx" do
      before do
        @hwpx_path = @data_folder + "/sample_math.hwpx"
        skip "sample_math.hwpx not found" unless File.exist?(@hwpx_path)
        @doc = Hwpx2md::Document.new(@hwpx_path)
      end

      it "creates a Document instance" do
        assert_instance_of Hwpx2md::Document, @doc
      end

      it "converts math content" do
        content = @doc.to_txt
        assert_instance_of String, content
      end
    end
  end

  describe "Document.open class method" do
    before do
      @data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
      @hwpx_path = @data_folder + "/sample1.hwpx"
      skip "sample1.hwpx not found" unless File.exist?(@hwpx_path)
    end

    it "opens document without block" do
      doc = Hwpx2md::Document.open(@hwpx_path)
      assert_instance_of Hwpx2md::Document, doc
    end
  end

  describe "document_properties" do
    before do
      @data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
      @hwpx_path = @data_folder + "/sample1.hwpx"
      skip "sample1.hwpx not found" unless File.exist?(@hwpx_path)
      @doc = Hwpx2md::Document.new(@hwpx_path)
    end

    it "returns a hash" do
      props = @doc.document_properties
      assert_instance_of Hash, props
    end

    it "includes font_size key" do
      props = @doc.document_properties
      assert props.key?(:font_size)
    end
  end

  describe "to_xml" do
    before do
      @data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
      @hwpx_path = @data_folder + "/sample1.hwpx"
      skip "sample1.hwpx not found" unless File.exist?(@hwpx_path)
      @doc = Hwpx2md::Document.new(@hwpx_path)
    end

    it "returns a Nokogiri XML document" do
      xml = @doc.to_xml
      assert_instance_of Nokogiri::XML::Document, xml
    end
  end

  describe "each_paragraph" do
    before do
      @data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
      @hwpx_path = @data_folder + "/sample1.hwpx"
      skip "sample1.hwpx not found" unless File.exist?(@hwpx_path)
      @doc = Hwpx2md::Document.new(@hwpx_path)
    end

    it "yields each paragraph" do
      count = 0
      @doc.each_paragraph { |p| count += 1 }
      assert_equal @doc.paragraphs.length, count
    end
  end

  describe "Korean text handling" do
    before do
      @data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
      @hwpx_path = @data_folder + "/sample1.hwpx"
      skip "sample1.hwpx not found" unless File.exist?(@hwpx_path)
      @doc = Hwpx2md::Document.new(@hwpx_path)
    end

    it "handles Korean characters in output" do
      content = @doc.to_txt
      # The content should be valid UTF-8
      assert content.valid_encoding?
      assert_equal Encoding::UTF_8, content.encoding
    end
  end
end
