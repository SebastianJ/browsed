
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "browsed/version"

Gem::Specification.new do |spec|
  spec.name          = "browsed"
  spec.version       = Browsed::VERSION
  spec.authors       = ["Sebastian"]
  spec.email         = ["sebastian.johnsson@gmail.com"]

  spec.summary       = %q{Browsed: Lightweight Capybara/PhantomJS/Selenium framework}
  spec.description   = %q{A lightweight framework for making it easier to work with Capybara/PhantomJS/Selenium}
  spec.homepage      = "https://github.com/SebastianJ"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_dependency "capybara", '>= 2.18'
  spec.add_dependency "poltergeist", '>= 1.18'
  spec.add_dependency "selenium-webdriver", '>= 3.9'
  spec.add_dependency "agents", '>= 0.1.4'
  spec.add_dependency "proxy_chain_rb", ">= 0.1.2"

  spec.add_development_dependency "rake", "~> 12.3.2"
  spec.add_development_dependency "rspec", "~> 3.8.0"
  spec.add_development_dependency "pry", "~> 0.12.2"
  spec.add_development_dependency "launchy", '~> 2.4', '>= 2.4.3'
end
