

### 2023-02-03
  - fix 『 character causing line break
    by add gsub! to xml

  ```
      @document_xml.gsub!(/<\/hp\:t><\/hp\:run><hp\:run charPrIDRef=\"\d+\"><hp\:t>/, "")


  ```