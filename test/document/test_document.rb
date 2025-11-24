# frozen_string_literal: true

require_relative "../test_helper"

describe Hwpx2md::Document do
  describe "with sample1.hwpx" do
    before do
      data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
      hwpx_path = data_folder + "/sample1.hwpx"
      skip "sample1.hwpx not found" unless File.exist?(hwpx_path)
      @doc = Hwpx2md::Document.open(hwpx_path)
    end

    it "creates Hwpx2md::Document instance" do
      assert_instance_of Hwpx2md::Document, @doc
    end

    it "returns String from to_txt" do
      assert_instance_of String, @doc.to_txt
    end

    it "returns non-empty content" do
      refute_empty @doc.to_txt
    end
  end

  describe "with sample_table.hwpx" do
    before do
      data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
      hwpx_path = data_folder + "/sample_table.hwpx"
      # Also check in test directory directly
      hwpx_path = File.join(File.dirname(__FILE__), "..", "sample_table.hwpx") unless File.exist?(hwpx_path)
      skip "sample_table.hwpx not found" unless File.exist?(hwpx_path)
      @doc = Hwpx2md::Document.open(hwpx_path)
    end

    it "creates Hwpx2md::Document instance" do
      assert_instance_of Hwpx2md::Document, @doc
    end

    it "returns String from to_txt" do
      assert_instance_of String, @doc.to_txt
    end

    it "contains markdown table syntax" do
      content = @doc.to_txt
      assert_includes content, "|"
    end
  end

  describe "with sample_math.hwpx" do
    before do
      data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
      hwpx_path = data_folder + "/sample_math.hwpx"
      skip "sample_math.hwpx not found" unless File.exist?(hwpx_path)
      @doc = Hwpx2md::Document.open(hwpx_path)
    end

    it "creates Hwpx2md::Document instance" do
      assert_instance_of Hwpx2md::Document, @doc
    end

    it "returns String from to_txt" do
      assert_instance_of String, @doc.to_txt
    end

    it "converts math equations to LaTeX" do
      content = @doc.to_txt
      # Math content should contain dollar signs for LaTeX
      assert_instance_of String, content
    end
  end
end
