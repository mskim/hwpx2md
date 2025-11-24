require 'hwpx2md/version'

module Hwpx2md #:nodoc:
  autoload :Document, 'hwpx2md/document'
  autoload :ImageExtractor, 'hwpx2md/image_extractor'
  autoload :StyleExtractor, 'hwpx2md/style_extractor'
end

require 'hwpx2md/core_ext/module'
require_relative 'eq_to_latex/syntax'
require_relative 'eq_to_latex/processor'
require_relative 'eq_to_latex/converter'
