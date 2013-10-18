Gem::Specification.new do |s|
  s.name = 'spacewalk-ui-porting'
  s.version = '0.1'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Duncan Mac-Vicar P.']
  s.homepage = 'http://github.com/dmacvicar/spacewalk-ui-porting'
  s.summary = 'Tool to aid jsp pages porting'
  s.description = 'Allows to replace obsolete tags in jsp files'

  s.required_rubygems_version = ">= 1.3.6"
  s.add_dependency('diffy')
end