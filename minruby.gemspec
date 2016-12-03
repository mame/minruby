# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "minruby"
  spec.version       = "1.0.3"
  spec.authors       = ["Yusuke Endoh"]
  spec.email         = ["mame@ruby-lang.org"]

  spec.summary       = %q{A helper library for "Ruby de manabu Ruby"}
  spec.description   = %q{This library provides some helper modules to implement a toy Ruby implementation.  This is created for a series of articles, "Ruby de manabu Ruby (Learning Ruby by implementing Ruby)", in ASCII.jp}
  spec.homepage      = "http://github.com/mame/minruby/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
