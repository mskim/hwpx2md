# hwpx2md

A ruby library/gem for converting hwpx file to markdown file.


## how to use the gem

```
require 'hwpx2md'

doc = Hwpx2md::Document.new("your_file.hwpx")

# Save as markdown
doc.save_as_markdown  # Automatically saves as your_file.md
# or
doc.save_as_markdown("custom_path.md")  # Save to a specific path

# Save as HTML
doc.save_as_html  # Automatically saves as your_file.html
# or
doc.save_as_html("custom_path.html")  # Save to a specific path with custom styling



hwpc_file_path = "~/Development/hwpx/sample1.hwpx
# Create a Docx::Document object for our existing docx file
doc = Docx::Document.open(hwpc_file_path)

# Retrieve and display paragraphs
doc.paragraphs.each do |p|
  puts p
end

```

## build and install locally
