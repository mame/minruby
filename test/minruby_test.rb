require 'test_helper'

class TTest < Minitest::Test
  def test_parse_literals
    assert_equal ["lit", 1], minruby_parse("1")
    assert_equal ["lit", -1], minruby_parse("-1")
    assert_equal ["lit", "foo"], minruby_parse("\"foo\"")
    assert_equal ["lit", nil], minruby_parse("nil")
    assert_equal ["lit", true], minruby_parse("true")
    assert_equal ["lit", false], minruby_parse("false")
  end

  def test_parse_binary
    assert_equal ["+" , ["lit", 1], ["lit", 2]], minruby_parse("1 + 2")
    assert_equal ["-" , ["lit", 1], ["lit", 2]], minruby_parse("1 - 2")
    assert_equal ["*" , ["lit", 1], ["lit", 2]], minruby_parse("1 * 2")
    assert_equal ["/" , ["lit", 1], ["lit", 2]], minruby_parse("1 / 2")
    assert_equal ["%" , ["lit", 1], ["lit", 2]], minruby_parse("1 % 2")
    assert_equal ["<" , ["lit", 1], ["lit", 2]], minruby_parse("1 < 2")
    assert_equal ["<=", ["lit", 1], ["lit", 2]], minruby_parse("1 <= 2")
    assert_equal ["==", ["lit", 1], ["lit", 2]], minruby_parse("1 == 2")
    assert_equal [">=", ["lit", 1], ["lit", 2]], minruby_parse("1 >= 2")
    assert_equal [">" , ["lit", 1], ["lit", 2]], minruby_parse("1 > 2")
  end

  def test_parse_stmts
    assert_equal ["stmts", ["lit", 1], ["lit", 2], ["lit", 3]], minruby_parse("1; 2; 3")
  end

  def test_parse_var
    assert_equal ["stmts", ["var_assign", "x", ["lit", 1]], ["var_ref", "x"]], minruby_parse("x = 1; x")
  end

  def test_parse_func_def
    assert_equal ["func_def", "foo", [], ["lit", 42]], minruby_parse("def foo() 42; end")
  end

  def test_parse_func_call
    assert_equal ["func_call", "foo", ["lit", 1], ["lit", 42]], minruby_parse("foo(1, 42)")
    assert_equal ["func_call", "foo", ["lit", 1], ["lit", 42]], minruby_parse("foo 1, 42")
  end

  def test_parse_if
    assert_equal ["if", ["lit", true], ["lit", 1], ["lit", 2]], minruby_parse("if true; 1 else 2 end")
    assert_equal ["if", ["lit", true], ["lit", 1], nil], minruby_parse("if true; 1 end")
    assert_equal ["if", ["lit", true], ["lit", 1], nil], minruby_parse("1 if true")
  end

  def test_parse_while
    assert_equal ["while", ["lit", true], ["lit", 1]], minruby_parse("while true; 1 end")
  end

  def test_parse_while2
    assert_equal ["while2", ["lit", true], ["lit", 1]], minruby_parse("begin 1; end while true")
  end

  def test_parse_ary
    assert_equal ["stmts",
      ["var_assign", "a", ["ary_new", ["lit", 1], ["lit", 2], ["lit", 3]]],
      ["ary_ref", ["var_ref", "a"], ["lit", 0]],
      ["ary_assign", ["var_ref", "a"], ["lit", 0], ["lit", 42]]
    ], minruby_parse("a = [1, 2, 3]; a[0]; a[0] = 42")
  end

  def test_parse_hash
    assert_equal ["stmts",
      ["var_assign", "h", ["hash_new", ["lit", "foo"], ["lit", 42]]],
      ["ary_ref", ["var_ref", "h"], ["lit", "foo"]],
      ["ary_assign", ["var_ref", "h"], ["lit", "foo"], ["lit", nil]]
    ], minruby_parse("h = {\"foo\" => 42}; h[\"foo\"]; h[\"foo\"] = nil")
  end

  def test_load
    argv = ARGV.dup
    ARGV.clear
    ARGV << __FILE__
    assert_equal File.read(__FILE__), minruby_load()
  ensure
    ARGV.clear
    ARGV.replace argv
  end

  def foo(x, y, z)
    x + y * z
  end

  def test_call
    assert_equal 7, minruby_call(:foo, [1, 2, 3])
  end
end
