# How XPath works

Nokogiri parses the XML files and organizes them as a file system, tree of nodes.


## How to implement table content extaxtion.

# this should tell whether is paragraph is table
def is_table?
  @node.xpath('.//hp:tbl')
  node.path.inclede?(tbl, tr, tc)