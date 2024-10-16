require 'hwpx2md/version'

module Hwpx2md #:nodoc:
  autoload :Document, 'hwpx2md/document'
end

require 'hwpx2md/core_ext/module'
# require 'eq_to_latext'
require 'byebug'
# require "eq_to_latex/version"
require_relative 'eq_to_latex/syntax'
require_relative 'eq_to_latex/processor'
require_relative 'eq_to_latex/converter'
