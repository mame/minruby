require "pp"
require "ripper"

class MinRubyParser
  def self.minruby_parse(program)
    MinRubyParser.new.minruby_parse(program)
  end

  def minruby_parse(program)
    simplify(Ripper.sexp(program))
  end

  def simplify(exp)
    case exp[0]
    when :program, :bodystmt
      make_stmts(exp[1])
    when :def
      name = exp[1][1]
      params = exp[2]
      params = params[1] if params[0] == :paren
      params = (params[1] || []).map {|a| a[1] }
      body = simplify(exp[3])
      ["func_def", name, params, body]
    when :call
      recv = simplify(exp[1])
      name = exp[3][1]
      ["method_call", recv, name, []]
    when :fcall
      name = exp[1][1]
      ["func_call", name]
    when :method_add_arg
      call = simplify(exp[1])
      e = exp[2]
      e = e[1] || [] if e[0] == :arg_paren
      e = e[1] || [] if e[0] == :args_add_block
      e = e.map {|e_| simplify(e_) }
      call[(call[0] == "func_call" ? 2 : 3)..-1] = e
      call
    when :command
      name = exp[1][1]
      args = exp[2][1].map {|e_| simplify(e_) }
      ["func_call", name, *args]
    when :if, :elsif
      cond_exp = simplify(exp[1])
      then_exp = make_stmts(exp[2])
      if exp[3]
        if exp[3][0] == :elsif
          else_exp = simplify(exp[3])
        else
          else_exp = make_stmts(exp[3][1])
        end
      end
      ["if", cond_exp, then_exp, else_exp]
    when :if_mod
      cond_exp = simplify(exp[1])
      then_exp = make_stmts([exp[2]])
      ["if", cond_exp, then_exp, nil]
    when :while
      cond_exp = simplify(exp[1])
      body_exp = make_stmts(exp[2])
      ["while", cond_exp, body_exp]
    when :while_mod
      cond_exp = simplify(exp[1])
      body_exp = make_stmts(exp[2][1][1])
      ["while2", cond_exp, body_exp]
    when :binary
      exp1 = simplify(exp[1])
      op = exp[2]
      exp2 = simplify(exp[3])
      [op.to_s, exp1, exp2]
    when :var_ref
      case exp[1][0]
      when :@kw
        case exp[1][1]
        when "nil" then ["lit", nil]
        when "true" then ["lit", true]
        when "false" then ["lit", false]
        else
          raise
        end
      when :@ident
        ["var_ref", exp[1][1]]
      when :@const
        ["const_ref", exp[1][1]]
      end
    when :@int
      ["lit", exp[1].to_i]
    when :unary
      v = simplify(exp[2])
      raise if v[0] != "lit"
      ["lit", -v[1]]
    when :string_literal
      ["lit", exp[1][1][1]]
    when :symbol_literal
      ["lit", exp[1][1][1].to_sym]
    when :assign
      case exp[1][0]
      when :var_field
        ["var_assign", exp[1][1][1], simplify(exp[2])]
      when :aref_field
        ["ary_assign", simplify(exp[1][1]), simplify(exp[1][2][1][0]), simplify(exp[2])]
      else
        raise
      end
    when :case
      arg = simplify(exp[1])
      when_clauses = []
      exp = exp[2]
      while exp && exp[0] == :when
        pat = exp[1].map {|e_| simplify(e_) }
        when_clauses << [pat, make_stmts(exp[2])]
        exp = exp[3]
      end
      else_clause = make_stmts(exp[1]) if exp
      #["case", arg, when_clauses, else_clause]

      exp = else_clause
      when_clauses.reverse_each do |patterns, stmts|
        patterns.each do |pattern|
          exp = ["if", ["==", arg, pattern], stmts, exp]
        end
      end
      exp
    when :method_add_block
      call = simplify(exp[1])
      blk_params = exp[2][1][1][1].map {|a| a[1] }
      blk_body = exp[2][2].map {|e_| simplify(e_) }
      call << blk_params << blk_body
    when :aref
      ["ary_ref", simplify(exp[1]), *exp[2][1].map {|e_| simplify(e_) }]
    when :array
      ["ary_new", *(exp[1] ? exp[1].map {|e_| simplify(e_) } : [])]
    when :hash
      kvs = ["hash_new"]
      if exp[1]
        exp[1][1].each do |e_|
          key = simplify(e_[1])
          val = simplify(e_[2])
          kvs << key << val
        end
      end
      kvs
    when :void_stmt
      ["lit", nil]
    when :paren
      simplify(exp[1][0])
    else
      pp exp
      raise "unsupported node: #{ exp[0] }"
    end
  end

  def make_stmts(exps)
    exps = exps.map {|exp| simplify(exp) }
    exps.size == 1 ? exps[0] : ["stmts", *exps]
  end
end

def minruby_load()
  File.read(ARGV.shift)
end

def minruby_parse(src)
  MinRubyParser.minruby_parse(src)
end

def minruby_call(mhd, args)
  send(mhd, *args)
end
