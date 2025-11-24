# frozen_string_literal: true

require_relative "test_helper"
require "open3"
require "tempfile"

describe "hwpx2md CLI" do
  before do
    @ruby = "/Users/mskim/.asdf/installs/ruby/3.4.3/bin/ruby"
    @cli = File.expand_path("../bin/hwpx2md", __dir__)
    @lib = File.expand_path("../lib", __dir__)
    @data_folder = File.expand_path("data", __dir__)
  end

  def run_cli(*args)
    cmd = [@ruby, "-I", @lib, @cli, *args]
    stdout, stderr, status = Open3.capture3(*cmd, chdir: File.expand_path("..", __dir__))
    [stdout + stderr, status]
  end

  describe "--help" do
    it "shows help message" do
      output, status = run_cli("--help")
      assert status.success?
      assert_includes output, "Usage: hwpx2md"
      assert_includes output, "--output"
      assert_includes output, "--verbose"
    end
  end

  describe "--version" do
    it "shows version" do
      output, status = run_cli("--version")
      assert status.success?
      assert_includes output, "hwpx2md"
      assert_match(/\d+\.\d+\.\d+/, output)
    end
  end

  describe "with no arguments" do
    it "shows error message" do
      output, status = run_cli
      refute status.success?
      assert_includes output, "Error"
      assert_includes output, "folder path"
    end
  end

  describe "with invalid directory" do
    it "shows error for non-existent directory" do
      output, status = run_cli("/nonexistent/path")
      refute status.success?
      assert_includes output, "not a valid directory"
    end

    it "shows error for file path" do
      skip "sample1.hwpx not found" unless File.exist?(File.join(@data_folder, "sample1.hwpx"))
      output, status = run_cli(File.join(@data_folder, "sample1.hwpx"))
      refute status.success?
      assert_includes output, "not a valid directory"
    end
  end

  describe "--dry-run" do
    before do
      skip "sample1.hwpx not found" unless File.exist?(File.join(@data_folder, "sample1.hwpx"))
    end

    it "shows what would be converted" do
      output, status = run_cli("--dry-run", "-v", @data_folder)
      assert status.success?
      assert_includes output, "[DRY RUN]"
      assert_includes output, "Would convert"
    end

    it "does not create files" do
      Dir.mktmpdir do |tmpdir|
        output, _status = run_cli("--dry-run", "-o", tmpdir, @data_folder)
        assert_includes output, "[DRY RUN]"
        assert_empty Dir.glob(File.join(tmpdir, "**/*.md"))
      end
    end
  end

  describe "conversion" do
    before do
      skip "sample1.hwpx not found" unless File.exist?(File.join(@data_folder, "sample1.hwpx"))
    end

    it "converts hwpx files to markdown" do
      Dir.mktmpdir do |tmpdir|
        output, status = run_cli("-o", tmpdir, @data_folder)
        assert status.success?
        assert_includes output, "succeeded"

        # Check that at least one md file was created
        md_files = Dir.glob(File.join(tmpdir, "**/*.md"))
        refute_empty md_files
      end
    end

    it "extracts styles with -s" do
      Dir.mktmpdir do |tmpdir|
        output, status = run_cli("-s", "-o", tmpdir, @data_folder)
        assert status.success?

        styles_dirs = Dir.glob(File.join(tmpdir, "**/styles"))
        refute_empty styles_dirs

        # Check for YAML files
        yml_files = Dir.glob(File.join(tmpdir, "**/styles/*.yml"))
        refute_empty yml_files
      end
    end

    it "respects --no-recursive" do
      Dir.mktmpdir do |tmpdir|
        # Create a subdirectory with a hwpx file would require setup
        # For now, just test that the option is accepted
        output, status = run_cli("--no-recursive", "-o", tmpdir, @data_folder)
        assert status.success?
      end
    end

    it "shows verbose output with -v" do
      Dir.mktmpdir do |tmpdir|
        output, status = run_cli("-v", "-o", tmpdir, @data_folder)
        assert status.success?
        assert_includes output, "Converting:"
        assert_includes output, "Found"
      end
    end
  end

  describe "error handling" do
    it "continues after conversion error" do
      Dir.mktmpdir do |tmpdir|
        # The data folder has some corrupt files, but should continue
        output, status = run_cli("-v", "-o", tmpdir, @data_folder)
        assert status.success?
        assert_includes output, "succeeded"
        assert_includes output, "failed"
      end
    end
  end
end
