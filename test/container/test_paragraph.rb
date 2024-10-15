require File.dirname(File.expand_path(__FILE__)) + "/../test_helper"

describe "paragraph" do
  before do
    data_foloder = File.dirname(File.dirname(File.expand_path(__FILE__))) + "/data"
    hwpx_path  = data_foloder + "/sample1.hwpx"
    @doc = Hwpx2md::Document.new(hwpx_path)
    @paragraphs = @doc.paragraphs
    @first_paragraph = @paragraphs.first
    @last_paragraph = @paragraphs.last

    @text_runs = @first_paragraph.text_runs
    @first_text_run = @text_runs.first
    @last_run = @text_runs.last

  end

  it "should create Hwpx2md::Elements::Containers::Paragraph class" do
    assert_equal Array, @paragraphs.class
    assert_equal Hwpx2md::Elements::Containers::Paragraph, @first_paragraph.class
  end

  it 'should create text_runs' do
    assert_equal Array, @text_runs.class
    # assert_equal Hwpx2md::Elements::Containers::TextRun, @first_text_run.class
    assert_equal Hwpx2md::Elements::Containers::Paragraph, @last_paragraph.class
    # assert_equal Hwpx2md::Elements::Containers::Table, @last_run.class
  end

end
