Gem::Specification.new do |s|
  s.name           = "tsubaiso-sdk"
  s.version        = "1.2.0"
  s.date           = "2017-08-01"
  s.summary        = "SDK for the Tsubaiso API"
  s.description    = "A library of methods that directly uses Tsubaiso API web endpoints."
  s.authors        = ["Tsubaiso, Inc."]
  s.email          = "apisupport@tsubaiso.net"
  s.files          = ["lib/tsubaiso_sdk.rb", "test/test_tsubaiso_sdk.rb", "Rakefile", "sample.rb", "README.md"]
  s.homepage       = "https://github.com/tsubaiso/tsubaiso-sdk-ruby"
  s.license        = "MIT"

  s.rubygems_version      = ">= 1.8.25"
  s.required_ruby_version = ">= 1.9.3"

  s.add_runtime_dependency     "json",     "~> 1.8", ">= 1.8.3"
  s.add_development_dependency "test-unit", "~> 3.0",">= 3.0.8"
end
