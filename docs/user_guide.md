# hwpx2md User Guide

A Ruby gem for converting HWPX files (Hangul Word Processor XML format) to Markdown and HTML.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hwpx2md'
```

And then execute:

```bash
bundle install
```

Or install it yourself:

```bash
gem install hwpx2md
```

**Requirements:** Ruby 3.1.0 or higher

## Command Line Interface (CLI)

The gem includes a CLI tool for batch converting HWPX files to Markdown.

### Basic Usage

```bash
# Convert all .hwpx files in a folder (and subfolders)
hwpx2md /path/to/folder

# Output to a specific directory
hwpx2md -o /output/folder /path/to/hwpx/files

# Preview what would be converted (dry run)
hwpx2md --dry-run /path/to/folder
```

### Options

```
-o, --output DIR       Output directory (default: same as input)
    --no-recursive     Don't process subfolders
-i, --[no-]images      Extract images (default: true)
-s, --[no-]styles      Extract styles to YAML (default: false)
-v, --verbose          Print verbose output
-n, --dry-run          Show what would be converted
-h, --help             Show help message
    --version          Show version
```

### Examples

```bash
# Convert without extracting images
hwpx2md --no-images /path/to/folder

# Convert with style extraction
hwpx2md -s -o /output/folder /path/to/folder

# Verbose output to see progress
hwpx2md -v /path/to/folder

# Convert only files in current folder (no subfolders)
hwpx2md --no-recursive /path/to/folder

# Combine options
hwpx2md --no-images -s -v -o /output /input
```

## Quick Start (Ruby API)

```ruby
require 'hwpx2md'

# Open a HWPX file
doc = Hwpx2md::Document.new("document.hwpx")

# Convert to Markdown and save
doc.save_as_markdown  # Saves as document.md

# Convert to HTML and save
doc.save_as_html  # Saves as document.html
```

## API Reference

### Opening Documents

There are two ways to open a HWPX document:

```ruby
# Using new
doc = Hwpx2md::Document.new("path/to/file.hwpx")

# Using open (alias for new)
doc = Hwpx2md::Document.open("path/to/file.hwpx")

# With a block (auto-closes when block ends)
Hwpx2md::Document.open("path/to/file.hwpx") do |doc|
  puts doc.to_markdown
end

# From an IO object or buffer
io = File.open("file.hwpx", "rb")
doc = Hwpx2md::Document.new(io)
```

### Converting to Markdown

```ruby
doc = Hwpx2md::Document.new("document.hwpx")

# Get markdown as a string
markdown_content = doc.to_markdown
# or
markdown_content = doc.to_txt

# Save to file (auto-generates filename from input)
doc.save_as_markdown  # Saves as document.md

# Save to a specific path
doc.save_as_markdown("output/converted.md")
```

### Converting to HTML

```ruby
doc = Hwpx2md::Document.new("document.hwpx")

# Get HTML as a string (includes basic styling)
html_content = doc.to_html

# Save to file (auto-generates filename from input)
doc.save_as_html  # Saves as document.html

# Save to a specific path
doc.save_as_html("output/converted.html")
```

The generated HTML includes:
- UTF-8 encoding
- Basic responsive styling
- Table formatting with borders and alternating row colors

### Working with Document Elements

#### Paragraphs

```ruby
doc = Hwpx2md::Document.new("document.hwpx")

# Get all paragraphs
paragraphs = doc.paragraphs

# Iterate over paragraphs
paragraphs.each do |paragraph|
  puts paragraph.to_s
end

# Using each_paragraph (deprecated but still available)
doc.each_paragraph do |p|
  puts p
end
```

#### Tables

```ruby
doc = Hwpx2md::Document.new("document.hwpx")

# Get all tables in the document
tables = doc.tables

# Each table can be converted to markdown
tables.each do |table|
  puts table.to_markdown
end
```

Tables are converted to GitHub-flavored Markdown format:

```markdown
| Header 1 | Header 2 | Header 3 |
|:---|:---|:---|
| Cell 1 | Cell 2 | Cell 3 |
| Cell 4 | Cell 5 | Cell 6 |
```

### Accessing Raw XML

```ruby
doc = Hwpx2md::Document.new("document.hwpx")

# Get the parsed Nokogiri XML document
xml_doc = doc.to_xml
```

### Document Properties

```ruby
doc = Hwpx2md::Document.new("document.hwpx")

# Get document properties
props = doc.document_properties
# => { font_size: 12, ... }
```

## Mathematical Equations

hwpx2md includes the `EqToLatex` module for converting Korean Hangul equation scripts to LaTeX format. This is automatically used when processing HWPX files containing mathematical equations.

### Manual Equation Conversion

```ruby
converter = EqToLatex::Converter.new

# Basic conversion (wraps in $ signs)
latex = converter.convert("a over b")
# => "$\\dfrac {a}{b}$"

# Without dollar signs
latex = converter.convert("a over b", dollar_sign: false)
# => "\\dfrac {a}{b}"

# With display mode (adds \displaystyle)
latex = converter.convert("sum from 1 to n", display_mode: true)
```

### Supported Equation Syntax

| Hangul Script | LaTeX Output |
|---------------|--------------|
| `a over b` | `\dfrac{a}{b}` |
| `sqrt a` | `\sqrt{a}` |
| `sqrt a of b` | `\sqrt[a]{b}` |
| `matrix {...}` | `\begin{matrix}...\end{matrix}` |
| `pmatrix {...}` | `\begin{pmatrix}...\end{pmatrix}` |
| `cases {...}` | `\begin{cases}...\end{cases}` |

## Examples

### Batch Conversion

```ruby
require 'hwpx2md'

Dir.glob("documents/*.hwpx").each do |hwpx_file|
  doc = Hwpx2md::Document.new(hwpx_file)
  doc.save_as_markdown
  puts "Converted: #{hwpx_file}"
end
```

### Extract Text Only

```ruby
require 'hwpx2md'

doc = Hwpx2md::Document.new("document.hwpx")
plain_text = doc.to_s
puts plain_text
```

### Custom HTML Output

```ruby
require 'hwpx2md'

doc = Hwpx2md::Document.new("document.hwpx")
markdown = doc.to_markdown

# Use your own markdown processor
require 'redcarpet'
renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
custom_html = renderer.render(markdown)
```

## Supported Content

- Paragraphs with text formatting
- Tables (converted to Markdown tables)
- Mathematical equations (converted to LaTeX)
- Footnotes
- Images (referenced)

## Troubleshooting

### File Not Found Error

```ruby
# Ensure the file exists and path is correct
doc = Hwpx2md::Document.new("/absolute/path/to/file.hwpx")
```

### Encoding Issues

The gem automatically handles UTF-8 encoding for Korean text. If you encounter encoding issues:

```ruby
# Force UTF-8 when reading output
content = doc.to_markdown.force_encoding('UTF-8')
```

### Invalid HWPX File

HWPX files are ZIP archives containing XML. If you receive errors about missing `Contents/section*.xml`, the file may be:
- A legacy HWP file (binary format, not supported)
- Corrupted
- Not a valid HWPX file

## License

MIT License
