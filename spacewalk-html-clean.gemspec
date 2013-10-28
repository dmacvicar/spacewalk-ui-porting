Gem::Specification.new do |s|
  s.name = 'spacewalk-html-clean'
  s.version = '0.1'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Duncan Mac-Vicar P.']
  s.homepage = 'http://github.com/dmacvicar/spacewalk-ui-porting'
  s.summary = 'Tool to aid jsp pages porting'
  s.description = 'Allows to replace obsolete tags in jsp files'
  s.platform = 'java'

  s.required_rubygems_version = ">= 1.3.6"
  s.add_dependency('diffy')
  s.add_dependency('clamp')
end