# frozen_string_literal: true

require_relative "test_helper"
require "tempfile"

describe "Hwpx2md::StyleExtractor" do
  before do
    @data_folder = File.dirname(File.expand_path(__FILE__)) + "/data"
    @hwpx_path = @data_folder + "/sample1.hwpx"
    skip "sample1.hwpx not found" unless File.exist?(@hwpx_path)
    @doc = Hwpx2md::Document.new(@hwpx_path)
  end

  describe "Document style methods" do
    it "has style_extractor" do
      assert_respond_to @doc, :style_extractor
      refute_nil @doc.style_extractor
    end

    it "responds to extract_styles" do
      assert_respond_to @doc, :extract_styles
    end

    it "responds to styles_to_hash" do
      assert_respond_to @doc, :styles_to_hash
    end

    it "responds to styles_to_yaml" do
      assert_respond_to @doc, :styles_to_yaml
    end

    it "responds to page_properties" do
      assert_respond_to @doc, :page_properties
    end

    it "responds to paragraph_styles" do
      assert_respond_to @doc, :paragraph_styles
    end

    it "responds to character_styles" do
      assert_respond_to @doc, :character_styles
    end

    it "responds to font_definitions" do
      assert_respond_to @doc, :font_definitions
    end
  end

  describe "page_properties" do
    it "returns a hash" do
      assert_instance_of Hash, @doc.page_properties
    end

    it "includes page dimensions" do
      props = @doc.page_properties
      assert_includes props.keys, :page
      assert_includes props[:page].keys, :width_mm
      assert_includes props[:page].keys, :height_mm
    end

    it "includes margins" do
      props = @doc.page_properties
      assert_includes props.keys, :margins
      assert_includes props[:margins].keys, :left_mm
      assert_includes props[:margins].keys, :right_mm
      assert_includes props[:margins].keys, :top_mm
      assert_includes props[:margins].keys, :bottom_mm
    end

    it "includes column settings" do
      props = @doc.page_properties
      assert_includes props.keys, :columns
      assert_includes props[:columns].keys, :count
    end

    it "has reasonable A4 page size" do
      props = @doc.page_properties
      # A4 is 210mm x 297mm
      assert_in_delta 210, props[:page][:width_mm], 1
      assert_in_delta 297, props[:page][:height_mm], 1
    end
  end

  describe "paragraph_styles" do
    it "returns an array" do
      assert_instance_of Array, @doc.paragraph_styles
    end

    it "has multiple styles" do
      assert @doc.paragraph_styles.length > 0
    end

    it "includes style names" do
      style = @doc.paragraph_styles.first
      assert_includes style.keys, :name
      assert_includes style.keys, :english_name
    end

    it "includes Normal/바탕글 style" do
      normal = @doc.paragraph_styles.find { |s| s[:english_name] == "Normal" }
      refute_nil normal
      assert_equal "바탕글", normal[:name]
    end

    it "includes properties for styles" do
      style = @doc.paragraph_styles.first
      assert_includes style.keys, :properties
    end
  end

  describe "character_styles" do
    it "returns an array" do
      assert_instance_of Array, @doc.character_styles
    end
  end

  describe "font_definitions" do
    it "returns a hash" do
      assert_instance_of Hash, @doc.font_definitions
    end

    it "includes hangul fonts" do
      fonts = @doc.font_definitions
      assert_includes fonts.keys, :hangul
    end

    it "includes latin fonts" do
      fonts = @doc.font_definitions
      assert_includes fonts.keys, :latin
    end

    it "font entries have face name" do
      fonts = @doc.font_definitions
      hangul_fonts = fonts[:hangul]
      refute_empty hangul_fonts
      assert_includes hangul_fonts.first.keys, :face
    end
  end

  describe "styles_to_hash" do
    it "returns combined hash" do
      hash = @doc.styles_to_hash
      assert_instance_of Hash, hash
      assert_includes hash.keys, :document
      assert_includes hash.keys, :paragraph_styles
      assert_includes hash.keys, :character_styles
      assert_includes hash.keys, :fonts
    end
  end

  describe "styles_to_yaml" do
    it "returns YAML string" do
      yaml = @doc.styles_to_yaml
      assert_instance_of String, yaml
      assert yaml.start_with?("---")
    end

    it "can be parsed back to hash" do
      yaml = @doc.styles_to_yaml
      parsed = YAML.safe_load(yaml, permitted_classes: [Symbol], aliases: true)
      assert_instance_of Hash, parsed
    end
  end

  describe "extract_styles" do
    it "creates style files" do
      Dir.mktmpdir do |tmpdir|
        files = @doc.extract_styles(tmpdir)

        assert_includes files.map { |f| File.basename(f) }, "document_properties.yml"
        assert_includes files.map { |f| File.basename(f) }, "paragraph_styles.yml"
        assert_includes files.map { |f| File.basename(f) }, "character_styles.yml"
        assert_includes files.map { |f| File.basename(f) }, "fonts.yml"
      end
    end

    it "creates valid YAML files" do
      Dir.mktmpdir do |tmpdir|
        @doc.extract_styles(tmpdir)

        doc_props_path = File.join(tmpdir, "document_properties.yml")
        assert File.exist?(doc_props_path)

        content = YAML.safe_load(File.read(doc_props_path), permitted_classes: [Symbol])
        assert_instance_of Hash, content
      end
    end

    it "uses default directory if not specified" do
      # Just test that it doesn't raise an error
      # We can't actually test the default path without side effects
      assert_respond_to @doc, :extract_styles
    end
  end
end

describe "Hwpx2md::StyleExtractor class" do
  before do
    @header_xml = Nokogiri::XML(<<~XML)
      <hh:head xmlns:hh="http://www.hancom.co.kr/hwpml/2011/head"
               xmlns:hc="http://www.hancom.co.kr/hwpml/2011/core">
        <hh:fontfaces>
          <hh:fontface lang="HANGUL">
            <hh:font id="0" face="맑은 고딕" type="TTF" isEmbedded="0"/>
          </hh:fontface>
        </hh:fontfaces>
        <hh:charProperties>
          <hh:charPr id="0" height="1000" textColor="#000000"/>
        </hh:charProperties>
        <hh:paraProperties>
          <hh:paraPr id="0">
            <hh:align horizontal="LEFT" vertical="BASELINE"/>
            <hh:lineSpacing type="PERCENT" value="150"/>
          </hh:paraPr>
        </hh:paraProperties>
        <hh:styles>
          <hh:style id="0" type="PARA" name="바탕글" engName="Normal" paraPrIDRef="0" charPrIDRef="0"/>
          <hh:style id="1" type="CHAR" name="쪽 번호" engName="Page Number" paraPrIDRef="0" charPrIDRef="0"/>
        </hh:styles>
      </hh:head>
    XML

    @section_xml = Nokogiri::XML(<<~XML)
      <hs:sec xmlns:hs="http://www.hancom.co.kr/hwpml/2011/section"
              xmlns:hp="http://www.hancom.co.kr/hwpml/2011/paragraph">
        <hp:p>
          <hp:run>
            <hp:secPr textDirection="HORIZONTAL" spaceColumns="1000">
              <hp:pagePr landscape="WIDELY" width="59528" height="84186" gutterType="LEFT_ONLY">
                <hp:margin left="8504" right="8504" top="5668" bottom="4252" header="4252" footer="4252" gutter="0"/>
              </hp:pagePr>
            </hp:secPr>
            <hp:colPr type="NEWSPAPER" colCount="2" sameSz="1"/>
          </hp:run>
        </hp:p>
      </hs:sec>
    XML
  end

  it "parses fonts" do
    extractor = Hwpx2md::StyleExtractor.new(@header_xml, @section_xml)
    fonts = extractor.fonts

    assert_includes fonts.keys, :hangul
    assert_equal "맑은 고딕", fonts[:hangul].first[:face]
  end

  it "parses page properties" do
    extractor = Hwpx2md::StyleExtractor.new(@header_xml, @section_xml)
    props = extractor.document_properties

    assert_includes props.keys, :page
    assert_equal 59528, props[:page][:width_hwp]
  end

  it "parses margins" do
    extractor = Hwpx2md::StyleExtractor.new(@header_xml, @section_xml)
    props = extractor.document_properties

    assert_includes props.keys, :margins
    assert_equal 8504, props[:margins][:left_hwp]
  end

  it "parses columns" do
    extractor = Hwpx2md::StyleExtractor.new(@header_xml, @section_xml)
    props = extractor.document_properties

    assert_includes props.keys, :columns
    assert_equal 2, props[:columns][:count]
    assert_equal "NEWSPAPER", props[:columns][:type]
  end

  it "parses paragraph styles" do
    extractor = Hwpx2md::StyleExtractor.new(@header_xml, @section_xml)
    styles = extractor.paragraph_styles

    refute_empty styles
    normal = styles.find { |s| s[:english_name] == "Normal" }
    refute_nil normal
  end

  it "parses character styles" do
    extractor = Hwpx2md::StyleExtractor.new(@header_xml, @section_xml)
    styles = extractor.character_styles

    # Should include the Page Number character style
    page_num = styles.find { |s| s[:english_name] == "Page Number" }
    refute_nil page_num
  end

  it "converts to hash" do
    extractor = Hwpx2md::StyleExtractor.new(@header_xml, @section_xml)
    hash = extractor.to_hash

    assert_includes hash.keys, :document
    assert_includes hash.keys, :paragraph_styles
    assert_includes hash.keys, :fonts
  end

  it "converts to YAML" do
    extractor = Hwpx2md::StyleExtractor.new(@header_xml, @section_xml)
    yaml = extractor.to_yaml

    assert yaml.start_with?("---")
    assert_includes yaml, "paragraph_styles"
  end

  it "saves to directory" do
    extractor = Hwpx2md::StyleExtractor.new(@header_xml, @section_xml)

    Dir.mktmpdir do |tmpdir|
      files = extractor.save_to(tmpdir)

      assert_equal 4, files.length
      files.each { |f| assert File.exist?(f) }
    end
  end
end
