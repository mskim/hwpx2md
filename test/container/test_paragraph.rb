# frozen_string_literal: true

require_relative "../test_helper"

describe "Hwpx2md::Elements::Containers::Paragraph" do
  before do
    data_folder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
    hwpx_path = data_folder + "/sample1.hwpx"
    skip "sample1.hwpx not found" unless File.exist?(hwpx_path)
    @doc = Hwpx2md::Document.new(hwpx_path)
    @paragraphs = @doc.paragraphs
    @first_paragraph = @paragraphs.first
    @last_paragraph = @paragraphs.last
  end

  describe "#paragraphs" do
    it "returns an Array" do
      assert_instance_of Array, @paragraphs
    end

    it "contains Paragraph objects" do
      assert_instance_of Hwpx2md::Elements::Containers::Paragraph, @first_paragraph
      assert_instance_of Hwpx2md::Elements::Containers::Paragraph, @last_paragraph
    end
  end

  describe "#text_runs" do
    it "returns an Array" do
      text_runs = @first_paragraph.text_runs
      assert_instance_of Array, text_runs
    end
  end

  describe "#to_s" do
    it "returns a String" do
      assert_instance_of String, @first_paragraph.to_s
    end
  end

  describe "#text" do
    it "is an alias for to_s" do
      assert_equal @first_paragraph.to_s, @first_paragraph.text
    end
  end

  describe "#each_text_run" do
    it "yields each text run" do
      count = 0
      @first_paragraph.each_text_run { |_tr| count += 1 }
      assert_equal @first_paragraph.text_runs.length, count
    end
  end

  describe "alignment methods" do
    it "responds to aligned_left?" do
      assert_respond_to @first_paragraph, :aligned_left?
    end

    it "responds to aligned_right?" do
      assert_respond_to @first_paragraph, :aligned_right?
    end

    it "responds to aligned_center?" do
      assert_respond_to @first_paragraph, :aligned_center?
    end
  end
end
