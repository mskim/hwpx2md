# frozen_string_literal: true

require_relative "test_helper"
require "tmpdir"
require "fileutils"

class TestTableConversion < Minitest::Test
  def setup
    @test_file_path = File.join(File.dirname(__FILE__), "sample_table.hwpx")
    skip "sample_table.hwpx not found" unless File.exist?(@test_file_path)
  end

  def test_document_creation
    doc = Hwpx2md::Document.new(@test_file_path)
    assert_instance_of Hwpx2md::Document, doc
  end

  def test_to_markdown_contains_table_structure
    doc = Hwpx2md::Document.new(@test_file_path)
    content = doc.to_markdown

    # Verify table content
    assert_includes content, "| 1-1 | 1-2 | 1-3 |"
    assert_includes content, "|:---|:---|:---|"
    assert_includes content, "| 2-1 | 2-2 | 2-3 |"
    assert_includes content, "| 3-1 | 3-2 | 3-3 |"
  end

  def test_save_as_markdown
    Dir.mktmpdir do |tmpdir|
      # Copy test file to temp directory
      temp_hwpx = File.join(tmpdir, "sample_table.hwpx")
      FileUtils.cp(@test_file_path, temp_hwpx)

      doc = Hwpx2md::Document.new(temp_hwpx)
      actual_path = doc.save_as_markdown

      expected_path = File.join(tmpdir, "sample_table.md")
      assert_equal expected_path, actual_path
      assert File.exist?(actual_path)

      content = File.read(actual_path, encoding: "UTF-8")
      assert_includes content, "| 1-1 | 1-2 | 1-3 |"
    end
  end

  def test_save_as_markdown_with_custom_path
    Dir.mktmpdir do |tmpdir|
      doc = Hwpx2md::Document.new(@test_file_path)
      custom_path = File.join(tmpdir, "custom_output.md")

      actual_path = doc.save_as_markdown(custom_path)
      assert_equal custom_path, actual_path
      assert File.exist?(actual_path)
    end
  end

  def test_to_html_structure
    doc = Hwpx2md::Document.new(@test_file_path)
    html_content = doc.to_html

    assert_includes html_content, "<!DOCTYPE html>"
    assert_includes html_content, "<table>"
    assert_includes html_content, "<tr>"
    assert_includes html_content, "<td"
  end

  def test_save_as_html
    Dir.mktmpdir do |tmpdir|
      temp_hwpx = File.join(tmpdir, "sample_table.hwpx")
      FileUtils.cp(@test_file_path, temp_hwpx)

      doc = Hwpx2md::Document.new(temp_hwpx)
      actual_path = doc.save_as_html

      expected_path = File.join(tmpdir, "sample_table.html")
      assert_equal expected_path, actual_path
      assert File.exist?(actual_path)

      html_content = File.read(actual_path, encoding: "UTF-8")
      assert_includes html_content, "<table>"
    end
  end

  def test_save_as_html_with_custom_path
    Dir.mktmpdir do |tmpdir|
      doc = Hwpx2md::Document.new(@test_file_path)
      custom_path = File.join(tmpdir, "custom_output.html")

      actual_path = doc.save_as_html(custom_path)
      assert_equal custom_path, actual_path
      assert File.exist?(actual_path)
    end
  end

  def test_tables_method
    doc = Hwpx2md::Document.new(@test_file_path)
    tables = doc.tables

    assert_instance_of Array, tables
    refute_empty tables
  end

  def test_html_contains_styling
    doc = Hwpx2md::Document.new(@test_file_path)
    html_content = doc.to_html

    assert_includes html_content, "<style>"
    assert_includes html_content, "border-collapse"
  end

  def test_utf8_encoding
    doc = Hwpx2md::Document.new(@test_file_path)
    content = doc.to_markdown

    assert content.valid_encoding?
    assert_equal Encoding::UTF_8, content.encoding
  end
end
