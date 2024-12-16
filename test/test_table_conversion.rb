# encoding: utf-8
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'hwpx2md'

class TestTableConversion < Minitest::Test
  def setup
    # Path to the sample table file
    @test_file_path = File.join(File.dirname(__FILE__), 'sample_table.hwpx')
    puts "\nUsing test file: #{@test_file_path}"
  end

  def test_table_conversion
    puts "\nUsing test file: #{@test_file_path}"
    
    doc = Hwpx2md::Document.new(@test_file_path)
    
    # Test markdown conversion
    md_output_path = @test_file_path.sub(/\.hwpx$/, '.md')
    puts "Output will be saved to: #{md_output_path}"
    
    actual_path = doc.save_as_markdown
    assert_equal md_output_path, actual_path
    
    content = File.read(actual_path, encoding: 'UTF-8')
    puts "\nContent saved to: #{actual_path}\n"
    puts content
    puts "\n---End of Content---\n"
    
    # Verify table content
    assert_includes content, "| 1-1 | 1-2 | 1-3 |"
    assert_includes content, "|:---|:---|:---|"
    assert_includes content, "| 2-1 | 2-2 | 2-3 |"
    assert_includes content, "| 3-1 | 3-2 | 3-3 |"
    
    # Test HTML conversion
    html_output_path = @test_file_path.sub(/\.hwpx$/, '.html')
    puts "\nHTML output will be saved to: #{html_output_path}"
    
    actual_html_path = doc.save_as_html
    assert_equal html_output_path, actual_html_path
    
    html_content = File.read(actual_html_path, encoding: 'UTF-8')
    assert_includes html_content, "<table>"
    assert_includes html_content, "<tr>"
    assert_includes html_content, 'style="text-align: left">1-1<'
  end
end
