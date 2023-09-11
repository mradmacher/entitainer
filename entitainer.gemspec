# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'entitainer'
  s.version = '0.0.1'
  s.summary = 'Immutable representations of database entities'
  s.authors = ['Michał Radmacher']
  s.email = 'michal@radmacher.pl'
  s.required_ruby_version = '>= 2.7.0'
  s.files = Dir['lib/**/*.rb']
  s.extra_rdoc_files = %w[README.md LICENSE]
  s.homepage = 'https://github.com/mradmacher/entitainer'
  s.license = 'MIT'
  s.metadata['rubygems_mfa_required'] = 'true'

  s.add_dependency 'optiomist', '~> 0.0.3'
end
