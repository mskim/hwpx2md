# hwpx2md

A ruby library/gem for converting hwpx file to markdown file.


## how to use the gem

```
require 'hwpx2md

hwpc_file_path = "~/Development/hwpx/sample1.hwpx


# Create a Docx::Document object for our existing docx file
doc = Docx::Document.open(hwpc_file_path)

# Retrieve and display paragraphs
doc.paragraphs.each do |p|
  puts p
end

```

## build and install locally
