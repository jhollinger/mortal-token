# encoding: utf-8
require File.join(File.dirname(__FILE__), 'lib', 'mortal-token', 'version')

Gem::Specification.new do |spec|
  spec.name = 'mortal-token'
  spec.version = MortalToken::VERSION
  spec.summary = "Generate self-destructing tokens"
  spec.description = "An wrapper library for generating self-contained, self-destructing tokens with HMAC"
  spec.authors = ['Jordan Hollinger']
  spec.date = '2015-12-09'
  spec.email = 'jordan@jordanhollinger.com'
  spec.homepage = 'http://github.com/jhollinger/mortal-token'

  spec.require_paths = ['lib']
  spec.files = [Dir.glob('lib/**/*'), 'README.md', 'LICENSE'].flatten

  spec.required_ruby_version = '>= 2.0.0'
end
