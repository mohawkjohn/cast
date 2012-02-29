######################################################################
#
# Tests for the preprocessor.
#
######################################################################

require 'test_helper'

class PreprocessorTest < Test::Unit::TestCase
  attr_accessor :cpp, :one_h, :two_h, :main_c, :text
  def setup
    @cpp = C::Preprocessor.new
    @cpp.pwd = TEST_DIR
    @cpp.include_path << 'dir1' << 'dir 2'
    FileUtils.rm_rf(TEST_DIR)
    FileUtils.mkdir_p(TEST_DIR)

    @one_h = "#{TEST_DIR}/one.h"
    @two_h = "#{TEST_DIR}/foo/two.h"
    @three_h = "#{TEST_DIR}/dir1/three.h"
    @main_c = "#{TEST_DIR}/main.c"
    File.open(@one_h, 'w'){|f| f.puts "int one = 1;"}
    FileUtils.mkdir(File.dirname(@two_h))
    File.open(@two_h, 'w'){|f| f.puts "int two = 2;"}
    FileUtils.mkdir(File.dirname(@three_h))
    File.open(@three_h, 'w'){|f| f.puts "int two = 2;"}
    @text = <<EOS
#include "one.h"
#include "foo/two.h"
int three = 3;
EOS
    File.open(@main_c, 'w'){|f| f.puts @text}
  end
  def teardown
    FileUtils.rm_rf(TEST_DIR)
  end
  def test_preprocess
    cpp.macros['V'] = 'int'
    cpp.macros['SWAP(a,b)'] = 'a ^= b ^= a ^= b'
    output = cpp.preprocess("V x; V y; void swap() { SWAP(x, y); }")
    assert_match(/x \^= y \^= x \^= y/, output)
    assert_match(/int x/, output)
  end
  def test_preprocess_include
    output = cpp.preprocess(text)
    assert_match(/int one = 1;/, output)
    assert_match(/int two = 2;/, output)
    assert_match(/int three = 3;/, output)
  end
  def test_preprocess_file
    output = cpp.preprocess_file(main_c)
    assert_match(/int one = 1;/, output)
    assert_match(/int two = 2;/, output)
    assert_match(/int three = 3;/, output)
  end
  def test_pwd
    assert_raise(C::Preprocessor::Error) { output = cpp.preprocess('#include "two.h"') }
    cpp.pwd = File.dirname(two_h)
    output = cpp.preprocess('#include "two.h"')
    assert_match(/int two = 2;/, output)
  end
  def test_get_all_includes
    File.open(one_h, 'a') {|f| f.puts '#include <stdarg.h>'}
    text_including_three = text + '#include "three.h"'
    includes = cpp.get_all_includes(text_including_three)
    assert !includes.grep(/stdarg.h/).empty?
    assert !includes.grep(/one.h/).empty?
    assert !includes.grep(/foo\/two.h/).empty?
    assert !includes.grep(/dir1\/three.h/).empty?
  end
  def test_get_project_includes
    File.open(one_h, 'a') {|f| f.puts '#include <stdarg.h>'}
    text_including_three = text + '#include "three.h"'
    includes = cpp.get_project_includes(text_including_three)
    assert includes.grep(/stdarg.h/).empty?
    assert !includes.grep(/one.h/).empty?
    assert !includes.grep(/foo\/two.h/).empty?
    assert !includes.grep(/dir1\/three.h/).empty?
  end
  def test_get_system_includes
    File.open(one_h, 'a') {|f| f.puts '#include <stdarg.h>'}
    text_including_three = text + '#include "three.h"'
    includes = cpp.get_system_includes(text_including_three)
    assert !includes.grep(/stdarg.h/).empty?
    assert includes.grep(/one.h/).empty?
    assert includes.grep(/foo\/two.h/).empty?
    assert includes.grep(/three.h/).empty?
  end
  def test_preprocess_no_line_markers
    output = cpp.preprocess("int one = 1;")
    assert_no_match(/^#/, output)
  end
end
