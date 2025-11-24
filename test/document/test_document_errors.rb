# frozen_string_literal: true

require_relative "../test_helper"
require "tempfile"

describe "Hwpx2md::Document error handling" do
  describe "invalid file path" do
    it "raises Zip::Error for non-existent file" do
      assert_raises(Zip::Error) do
        Hwpx2md::Document.new("/non/existent/path/file.hwpx")
      end
    end
  end

  describe "invalid file format" do
    it "raises error for non-zip file" do
      Tempfile.create(["test", ".hwpx"]) do |f|
        f.write("This is not a zip file")
        f.flush
        assert_raises(Zip::Error) do
          Hwpx2md::Document.new(f.path)
        end
      end
    end

    it "raises Errno::ENOENT for zip without section XML" do
      # Create a valid zip but without the required Contents/section*.xml
      require "zip"
      Dir.mktmpdir do |tmpdir|
        zip_path = File.join(tmpdir, "test.hwpx")
        Zip::File.open(zip_path, create: true) do |zip|
          zip.get_output_stream("dummy.txt") { |os| os.write("dummy content") }
        end

        assert_raises(Errno::ENOENT) do
          Hwpx2md::Document.new(zip_path)
        end
      end
    end
  end

  describe "save_as_markdown" do
    before do
      @data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
      @hwpx_path = @data_folder + "/sample1.hwpx"
      skip "sample1.hwpx not found" unless File.exist?(@hwpx_path)
    end

    it "saves to default path based on input filename" do
      Dir.mktmpdir do |tmpdir|
        # Copy file to temp dir
        temp_hwpx = File.join(tmpdir, "test_doc.hwpx")
        FileUtils.cp(@hwpx_path, temp_hwpx)

        doc = Hwpx2md::Document.new(temp_hwpx)
        result_path = doc.save_as_markdown

        expected_path = File.join(tmpdir, "test_doc.md")
        assert_equal expected_path, result_path
        assert File.exist?(result_path)
      end
    end

    it "saves to custom path when provided" do
      Dir.mktmpdir do |tmpdir|
        doc = Hwpx2md::Document.new(@hwpx_path)
        custom_path = File.join(tmpdir, "custom_output.md")
        result_path = doc.save_as_markdown(custom_path)

        assert_equal custom_path, result_path
        assert File.exist?(result_path)
      end
    end

    it "writes UTF-8 encoded content" do
      Dir.mktmpdir do |tmpdir|
        doc = Hwpx2md::Document.new(@hwpx_path)
        output_path = File.join(tmpdir, "output.md")
        doc.save_as_markdown(output_path)

        content = File.read(output_path, encoding: "UTF-8")
        assert content.valid_encoding?
      end
    end
  end

  describe "save_as_html" do
    before do
      @data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
      @hwpx_path = @data_folder + "/sample1.hwpx"
      skip "sample1.hwpx not found" unless File.exist?(@hwpx_path)
    end

    it "saves to default path based on input filename" do
      Dir.mktmpdir do |tmpdir|
        temp_hwpx = File.join(tmpdir, "test_doc.hwpx")
        FileUtils.cp(@hwpx_path, temp_hwpx)

        doc = Hwpx2md::Document.new(temp_hwpx)
        result_path = doc.save_as_html

        expected_path = File.join(tmpdir, "test_doc.html")
        assert_equal expected_path, result_path
        assert File.exist?(result_path)
      end
    end

    it "saves to custom path when provided" do
      Dir.mktmpdir do |tmpdir|
        doc = Hwpx2md::Document.new(@hwpx_path)
        custom_path = File.join(tmpdir, "custom_output.html")
        result_path = doc.save_as_html(custom_path)

        assert_equal custom_path, result_path
        assert File.exist?(result_path)
      end
    end

    it "generates valid HTML structure" do
      Dir.mktmpdir do |tmpdir|
        doc = Hwpx2md::Document.new(@hwpx_path)
        output_path = File.join(tmpdir, "output.html")
        doc.save_as_html(output_path)

        content = File.read(output_path, encoding: "UTF-8")
        assert_includes content, "<!DOCTYPE html>"
        assert_includes content, "<html>"
        assert_includes content, "</html>"
        assert_includes content, "<head>"
        assert_includes content, "<body>"
        assert_includes content, 'charset="UTF-8"'
      end
    end

    it "includes CSS styling" do
      Dir.mktmpdir do |tmpdir|
        doc = Hwpx2md::Document.new(@hwpx_path)
        output_path = File.join(tmpdir, "output.html")
        doc.save_as_html(output_path)

        content = File.read(output_path, encoding: "UTF-8")
        assert_includes content, "<style>"
        assert_includes content, "font-family"
      end
    end
  end

  describe "to_html" do
    before do
      @data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
      @hwpx_path = @data_folder + "/sample1.hwpx"
      skip "sample1.hwpx not found" unless File.exist?(@hwpx_path)
      @doc = Hwpx2md::Document.new(@hwpx_path)
    end

    it "returns HTML string" do
      html = @doc.to_html
      assert_instance_of String, html
      assert_includes html, "<html>"
    end

    it "includes table styling" do
      html = @doc.to_html
      assert_includes html, "border-collapse"
    end
  end
end
