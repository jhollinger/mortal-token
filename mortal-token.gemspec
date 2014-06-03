# encoding: utf-8
require File.join(File.dirname(__FILE__), 'lib', 'mortal-token', 'version')

Gem::Specification.new do |spec|
  spec.name = 'mortal-token'
  spec.version = MortalToken::VERSION
  spec.summary = "Generate self-destructing tokens"
  spec.description = "An wrapper library for generating self-contained, self-destructing tokens with HMAC"
  spec.authors = ['Jordan Hollinger']
  spec.date = '2014-06-03'
  spec.email = 'jordan@jordanhollinger.com'
  spec.homepage = 'http://github.com/jhollinger/mortal-token'

  spec.require_paths = ['lib']
  spec.files = [Dir.glob('lib/**/*'), 'README.rdoc', 'LICENSE'].flatten

  spec.specification_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION if spec.respond_to? :specification_version
end
