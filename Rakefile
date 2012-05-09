# -*- mode: ruby -*-

require 'rubygems'

# Fix for problem described here: https://github.com/jbarnette/isolate/pull/39
module Gem
  Deprecate = Module.new do
    include Deprecate
  end
end
require 'isolate/now'


require 'hoe'

Hoe.plugin :compiler
Hoe.plugin :git

h = Hoe.spec 'cast' do
  self.require_ruby_version ">=1.9"
  self.developer('George Ogata', 'george.ogata@gmail.com')
  self.readme_file = 'README.rdoc'
  self.spec_extras[:name] = "csquare-cast"
end

task :default => :test

require 'rake/testtask'

dlext = RbConfig::CONFIG['DLEXT']


# lexer
file 'ext/cast/yylex.c' => 'ext/cast/yylex.re' do |t|
  sh "re2c #{t.prerequisites[0]} > #{t.name}"
end

# parser
file 'lib/cast/c.tab.rb' => 'lib/cast/c.y' do |t|
  sh "racc #{t.prerequisites[0]}"
end

desc "Run unit tests."
Rake::TestTask.new(:test => :lib) do |t|
  t.libs << 'ext' << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

desc "Run irb with cast loaded."
task :irb => :compile do
  sh 'irb -Ilib:ext -rcast'
end


