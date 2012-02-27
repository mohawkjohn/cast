# -*- mode: ruby -*-

task :default => :test

require 'rake/testtask'

dlext = RbConfig::CONFIG['DLEXT']

# cast_ext
file "ext/cast/cast_ext.#{dlext}" =>
     FileList['ext/cast/*.c', 'ext/cast/yylex.c'] do |t|
  cd 'ext/cast' do
    ruby 'extconf.rb'
    sh 'make'
  end
end

# lexer
file 'ext/cast/yylex.c' => 'ext/cast/yylex.re' do |t|
  sh "re2c #{t.prerequisites[0]} > #{t.name}"
end

# parser
file 'lib/cast/c.tab.rb' => 'lib/cast/c.y' do |t|
  sh "racc #{t.prerequisites[0]}"
end

desc "Build."
task :lib =>
  FileList['lib/cast/c.tab.rb',
           "ext/cast/cast_ext.#{dlext}"]

desc "Run unit tests."
Rake::TestTask.new(:test => :lib) do |t|
  t.libs << 'ext' << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

desc "Run irb with cast loaded."
task :irb => :lib do
  sh 'irb -Ilib:ext -rcast'
end

desc "Remove temporary files in build process"
task :clean do
  rm_f 'ext/cast/*.o'
end

desc "Remove all files built from initial source files"
task :clobber => [:clean] do
  rm_f 'ext/cast/Makefile'
  rm_f Dir['ext/cast/*.{bundle,dll,o,so}']
  rm_f 'ext/cast/yylex.c'
  rm_f 'lib/cast/c.tab.rb'
end

