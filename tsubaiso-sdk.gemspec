Gem::Specification.new do |s|
  s.name           = 'tsubaiso-sdk'
  s.version        = '1.2.19'
  s.date           = '2025-01-15'
  s.summary        = 'SDK for the Tsubaiso API'
  s.description    = 'A library of methods that directly uses Tsubaiso API web endpoints.'
  s.authors        = ['Tsubaiso, Inc.']
  s.email          = 'apisupport@tsubaiso.net'
  s.files          = ['lib/tsubaiso_sdk.rb',
                      'lib/tsubaiso_api.rb',
                      'test/test_tsubaiso_api.rb',
                      'test/stubbings/stub_register.rb',
                      'Rakefile', 'sample.rb',
                      'README.md']
  s.files         += Dir['test/fixtures/*.json', 'test/tsubaiso_sdk/*.rb']
  s.homepage       = 'https://github.com/tsubaiso/tsubaiso-sdk-ruby'
  s.license        = 'MIT'

  s.rubygems_version      = '>= 1.8.25'
  s.required_ruby_version = '>= 2.2'

  s.add_runtime_dependency     'json',     '~> 2.6', '>= 2.6.3'
  s.add_development_dependency 'minitest', '~> 5.4', '>= 5.4.3'
end
