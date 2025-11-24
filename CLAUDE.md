# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

hwpx2md is a Ruby gem that converts HWPX files (Hangul Word Processor XML format) to Markdown and HTML. It uses rubyzip to extract the HWPX archive and nokogiri to parse the XML content.

## Build & Test Commands

```bash
# Install dependencies
bundle install

# Build and install the gem locally
gem build hwpx2md.gemspec
gem install hwpx2md-*.gem

# Run tests (uses minitest with spec-style syntax)
ruby -Ilib:test test/document/test_document.rb
ruby -Ilib:test test/container/test_paragraph.rb
ruby -Ilib:test test/test_table_conversion.rb

# Interactive console with library loaded
rake console
```

## Architecture

### Core Components

- **Hwpx2md::Document** (`lib/hwpx2md/document.rb`): Main entry point. Opens HWPX files (ZIP archives), extracts `Contents/section*.xml`, and provides conversion methods (`to_txt`, `to_markdown`, `to_html`, `save_as_markdown`, `save_as_html`).

- **Containers** (`lib/hwpx2md/containers/`): Parse HWPX XML nodes into structured objects:
  - `Paragraph` - Text paragraphs with formatting
  - `Table`, `TableRow`, `TableCell`, `TableColumn` - Table structures
  - `TextRun` - Styled text segments
  - `MathNode` - Mathematical equations
  - `FootnoteNode` - Footnotes
  - `ImageNode` - Embedded images

- **EqToLatex** (`lib/eq_to_latex/`): Converts Korean Hangul equation script to LaTeX syntax:
  - `Converter` - Main conversion logic
  - `Syntax` - Keyword mappings and regex patterns
  - `Processor` - Pre/post processing

### HWPX File Structure

HWPX files are ZIP archives containing XML. The gem reads `Contents/section*.xml` for document content. XML uses `hp:` namespace for elements (paragraphs: `hp:p`, tables: `hp:tbl`, text: `hp:t`).

## Testing

Use minitest with spec-style (`describe`/`it` blocks). Test files are in `test/` directory. Test data (`.hwpx` sample files) is in `test/data/`.
