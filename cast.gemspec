spec = Gem::Specification.new do |s|
  s.name = 'cast'
  s.summary = "C parser and AST constructor."
  s.version = '0.2.0'
  s.author = 'George Ogata'
  s.email = 'george.ogata@gmail.com'
  s.homepage = 'http://cast.rubyforge.org'
  s.rubyforge_project = 'cast'

  s.platform = Gem::Platform::RUBY
  s.extensions << 'ext/cast/extconf.rb'
  s.files = Dir['README', 'ChangeLog', '{lib,ext,doc,test}/**/*'] - Dir['ext/**/*.{bundle,so,o}']
  s.test_files = Dir['test/*']

  s.add_development_dependency 'racc'
  s.requirements << 're2c for development'
  s.requirements << 'a precompiler such as GCC'
  s.post_install_message =<<MSG
****************************************************
Make sure you have the C preprocessor for your Ruby.
To find the C preprocessor command for your Ruby:

ruby -rrbconfig -e "puts RbConfig::CONFIG['CPP']"
****************************************************
MSG
end
