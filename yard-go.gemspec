require File.expand_path('../lib/yard-go/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = "yard-go"
  s.summary       = "YARD plugin for documenting Go source code"
  s.version       = YARDGo::VERSION
  s.date          = Time.now.strftime('%Y-%m-%d')
  s.author        = "Loren Segal"
  s.email         = "lsegal@soen.ca"
  s.homepage      = "http://github.com/lsegal/yard-go"
  s.platform      = Gem::Platform::RUBY
  s.files         = Dir.glob("{lib,templates}/**/*") +
                    ['LICENSE.txt', 'README.md', __FILE__]
  s.require_paths = ['lib']
end
