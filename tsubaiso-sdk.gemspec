Gem::Specification.new do |s|
  s.name = "tsubaiso-sdk"
  s.version = "1.0.0"
  s.date = "2015-10-16"
  s.summary = "SDK for the Tsubaiso API"
  s.description = "A library of methods that directly uses Tsubaiso API web endpoints."
  s.authors = ["Tsubaiso, Inc."]
  s.email = "apisupport@tsubaiso.net"
  s.files = ["lib/tsubaiso_sdk.rb", "test/test_tsubaiso_sdk.rb", "Rakefile", "sample.rb", "README.md", "README-j.md"]
  s.homepage = "https://github.com/tsubaiso/tsubaiso-sdk-ruby"
  s.license = "MIT"
  s.add_dependency "json"
  s.add_development_dependency "minitest"
end
