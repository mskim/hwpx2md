$:.unshift File.expand_path("../lib", __FILE__)
require 'hwpx2md/version'

Gem::Specification.new do |s|
  s.name        = 'hwpx2md'
  s.version     = Hwpx2md::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'a ruby library/gem for converting hwpx files to markdown'
  s.description = 'Convert HWPX (Hancom Office) files to Markdown or HTML. Supports tables, math equations (LaTeX), images, and style extraction.'
  s.authors     = ['Min Soo Kim']
  s.email       = ['mskim@gmail.com']
  s.homepage    = 'https://github.com/mskim/hwpx2md'
  s.files       = Dir['README.md', 'LICENSE.md', 'lib/**/*.rb', 'bin/*']
  s.bindir      = 'bin'
  s.executables = ['hwpx2md']
  s.required_ruby_version = '>= 3.1.0'

  s.add_dependency 'nokogiri', '~> 1.18'
  s.add_dependency 'rubyzip',  '~> 3.2'
  s.add_dependency 'kramdown', '~> 2.5'

  s.add_development_dependency 'minitest', '~> 5.25'
  s.add_development_dependency 'rake', '~> 13.2'
  s.add_development_dependency 'debug', '~> 1.9'
end
