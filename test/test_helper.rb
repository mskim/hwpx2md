#!/usr/bin/env ruby
# encoding: utf-8
require 'debug'
require 'minitest/autorun'
# $LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
# $LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

# $LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')
# $LOAD_PATH.unshift File.dirname(__FILE__), '../..'
# require File.join(File.dirname(__FILE__), '..', 'lib') + "/hwpx2md"
# require File.join(File.dirname(__FILE__), '..', 'lib') + "/eq_to_latex"
# include Hwpx2md

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "hwpx2md"

require "minitest/autorun"
