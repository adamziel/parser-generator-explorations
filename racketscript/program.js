import * as $rjs_core from '../runtime/core.js';
import * as M0 from "../runtime/kernel.rkt.js";
import * as M1 from "../links/parser-tools-lib/parser-tools/lex.rkt.js";
import * as M2 from "../collects/racket/private/misc.rkt.js";
import * as M3 from "../links/parser-tools-lib/parser-tools/yacc.rkt.js";
import * as M4 from "../collects/racket/match/runtime.rkt.js";
import * as M5 from "../collects/racket/private/modbeg.rkt.js";
import * as M6 from "../runtime/read.rkt.js";
import * as M7 from "../runtime/unsafe.rkt.js";
import * as M8 from "../links/parser-tools-lib/parser-tools/private-lex/token.rkt.js";
var token_NUM = function(x1) {
  if (arguments.length !== 1) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return M8.make_token($rjs_core.PrimitiveSymbol.make("NUM"), x1);
};
var token_VAR = function(x2) {
  if (arguments.length !== 1) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return M8.make_token($rjs_core.PrimitiveSymbol.make("VAR"), x2);
};
var token__plus_ = function() {
  if (arguments.length !== 0) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return $rjs_core.PrimitiveSymbol.make("+");
};
var token__ = function() {
  if (arguments.length !== 0) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return $rjs_core.PrimitiveSymbol.make("-");
};
var token_EOF = function() {
  if (arguments.length !== 0) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return $rjs_core.PrimitiveSymbol.make("EOF");
};
var token_LET = function() {
  if (arguments.length !== 0) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return $rjs_core.PrimitiveSymbol.make("LET");
};
var token_IN = function() {
  if (arguments.length !== 0) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return $rjs_core.PrimitiveSymbol.make("IN");
};
var g19353 = function(start_pos_p10, end_pos_p11, lexeme_p12, input_port_p13) {
  if (arguments.length !== 4) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return token__();
};
var g19364 = function(start_pos_p14, end_pos_p15, lexeme_p16, input_port_p17) {
  if (arguments.length !== 4) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return token__plus_();
};
var g19375 = function(start_pos_p18, end_pos_p19, lexeme_p20, input_port_p21) {
  if (arguments.length !== 4) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return token_LET();
};
var g19386 = function(start_pos_p22, end_pos_p23, lexeme_p24, input_port_p25) {
  if (arguments.length !== 4) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return token_IN();
};
var g19397 = function(start_pos_p26, end_pos_p27, lexeme_p28, input_port_p29) {
  if (arguments.length !== 4) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return token_NUM(M0.string__gt_number(lexeme_p28));
};
var g19408 = function(start_pos_p30, end_pos_p31, lexeme_p32, input_port_p33) {
  if (arguments.length !== 4) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return token_VAR(lexeme_p32);
};
var g19419 = function(start_pos_p34, end_pos_p35, lexeme_p36, input_port_p37) {
  if (arguments.length !== 4) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return simple_math_lexer(input_port_p37);
};
var proc38 = M1.__rjs_quoted__.lexer_body(0, $rjs_core.Vector.make([$rjs_core.Vector.make([$rjs_core.Vector.make([9, 13, 1]), $rjs_core.Vector.make([32, 32, 1]), $rjs_core.Vector.make([33, 33, 4]), $rjs_core.Vector.make([36, 38, 4]), $rjs_core.Vector.make([43, 43, 6]), $rjs_core.Vector.make([45, 45, 7]), $rjs_core.Vector.make([48, 57, 5]), $rjs_core.Vector.make([58, 58, 4]), $rjs_core.Vector.make([63, 63, 4]), $rjs_core.Vector.make([65, 104, 4]), $rjs_core.Vector.make([105, 105, 2]), $rjs_core.Vector.make([106, 107, 4]), $rjs_core.Vector.make([108, 108, 3]), $rjs_core.Vector.make([109, 122, 4]), $rjs_core.Vector.make([133, 133, 1]), $rjs_core.Vector.make([160, 160, 1]), $rjs_core.Vector.make([5760, 5760, 1]), $rjs_core.Vector.make([8192, 8202, 1]), $rjs_core.Vector.make([8232, 8233, 1]), $rjs_core.Vector.make([8239, 8239, 1]), $rjs_core.Vector.make([8287, 8287, 1]), $rjs_core.Vector.make([12288, 12288, 1])]), false, $rjs_core.Vector.make([$rjs_core.Vector.make([33, 33, 4]), $rjs_core.Vector.make([36, 38, 4]), $rjs_core.Vector.make([58, 58, 4]), $rjs_core.Vector.make([63, 63, 4]), $rjs_core.Vector.make([65, 109, 4]), $rjs_core.Vector.make([110, 110, 11]), $rjs_core.Vector.make([111, 122, 4])]), $rjs_core.Vector.make([$rjs_core.Vector.make([33, 33, 4]), $rjs_core.Vector.make([36, 38, 4]), $rjs_core.Vector.make([58, 58, 4]), $rjs_core.Vector.make([63, 63, 4]), $rjs_core.Vector.make([65, 100, 4]), $rjs_core.Vector.make([101, 101, 10]), $rjs_core.Vector.make([102, 122, 4])]), $rjs_core.Vector.make([$rjs_core.Vector.make([33, 33, 4]), $rjs_core.Vector.make([36, 38, 4]), $rjs_core.Vector.make([58, 58, 4]), $rjs_core.Vector.make([63, 63, 4]), $rjs_core.Vector.make([65, 122, 4])]), $rjs_core.Vector.make([$rjs_core.Vector.make([43, 43, 8]), $rjs_core.Vector.make([45, 45, 8]), $rjs_core.Vector.make([46, 46, 9]), $rjs_core.Vector.make([48, 57, 5])]), $rjs_core.Vector.make([$rjs_core.Vector.make([48, 57, 5])]), $rjs_core.Vector.make([$rjs_core.Vector.make([48, 57, 5])]), $rjs_core.Vector.make([$rjs_core.Vector.make([48, 57, 5])]), $rjs_core.Vector.make([$rjs_core.Vector.make([43, 43, 8]), $rjs_core.Vector.make([45, 45, 8]), $rjs_core.Vector.make([48, 57, 13])]), $rjs_core.Vector.make([$rjs_core.Vector.make([33, 33, 4]), $rjs_core.Vector.make([36, 38, 4]), $rjs_core.Vector.make([58, 58, 4]), $rjs_core.Vector.make([63, 63, 4]), $rjs_core.Vector.make([65, 115, 4]), $rjs_core.Vector.make([116, 116, 12]), $rjs_core.Vector.make([117, 122, 4])]), $rjs_core.Vector.make([$rjs_core.Vector.make([33, 33, 4]), $rjs_core.Vector.make([36, 38, 4]), $rjs_core.Vector.make([58, 58, 4]), $rjs_core.Vector.make([63, 63, 4]), $rjs_core.Vector.make([65, 122, 4])]), $rjs_core.Vector.make([$rjs_core.Vector.make([33, 33, 4]), $rjs_core.Vector.make([36, 38, 4]), $rjs_core.Vector.make([58, 58, 4]), $rjs_core.Vector.make([63, 63, 4]), $rjs_core.Vector.make([65, 122, 4])]), $rjs_core.Vector.make([$rjs_core.Vector.make([43, 43, 8]), $rjs_core.Vector.make([45, 45, 8]), $rjs_core.Vector.make([46, 46, 9]), $rjs_core.Vector.make([48, 57, 13])])]), M0.vector(false, g19419, g19408, g19408, g19408, g19397, g19364, g19353, false, g19397, g19408, g19386, g19375, g19397), $rjs_core.Vector.make([false, true, false, false, false, false, false, false, false, false, false, false, false, false]), function(start_pos_p39, end_pos_p40, lexeme_p41, input_port_p42) {
  if (arguments.length !== 4) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return M0.rvoid();
}, false, function(start_pos_p43, end_pos_p44, lexeme_p45, input_port_p46) {
  if (arguments.length !== 4) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return false;
}, function(start_pos_p47, end_pos_p48, lexeme_p49, input_port_p50) {
  if (arguments.length !== 4) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return token_EOF();
});
var simple_math_lexer = function(port51) {
  if (arguments.length !== 1) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return proc38(port51);
};
var let_result1 = M0.make_struct_type($rjs_core.PrimitiveSymbol.make("let-exp"), false, 3, 0, false, M0.rnull, M0.current_inspector(), false, $rjs_core.Pair.makeList(0, 1, 2), false, $rjs_core.PrimitiveSymbol.make("let-exp"));
var struct_52 = let_result1.getAt(0);
var make_53 = let_result1.getAt(1);
var __p54 = let_result1.getAt(2);
var __ref55 = let_result1.getAt(3);
var __set_bang_56 = let_result1.getAt(4);
var let_result2 = M0.values(struct_52, make_53, __p54, M0.make_struct_field_accessor(__ref55, 0, $rjs_core.PrimitiveSymbol.make("var")), M0.make_struct_field_accessor(__ref55, 1, $rjs_core.PrimitiveSymbol.make("num")), M0.make_struct_field_accessor(__ref55, 2, $rjs_core.PrimitiveSymbol.make("exp")));
var struct_let_exp = let_result2.getAt(0);
var make_let_exp = let_result2.getAt(1);
var let_exp_p = let_result2.getAt(2);
var let_exp_var = let_result2.getAt(3);
var let_exp_num = let_result2.getAt(4);
var let_exp_exp = let_result2.getAt(5);
var let_result3 = M0.make_struct_type($rjs_core.PrimitiveSymbol.make("arith-exp"), false, 3, 0, false, M0.rnull, M0.current_inspector(), false, $rjs_core.Pair.makeList(0, 1, 2), false, $rjs_core.PrimitiveSymbol.make("arith-exp"));
var struct_57 = let_result3.getAt(0);
var make_58 = let_result3.getAt(1);
var __p59 = let_result3.getAt(2);
var __ref60 = let_result3.getAt(3);
var __set_bang_61 = let_result3.getAt(4);
var let_result4 = M0.values(struct_57, make_58, __p59, M0.make_struct_field_accessor(__ref60, 0, $rjs_core.PrimitiveSymbol.make("op")), M0.make_struct_field_accessor(__ref60, 1, $rjs_core.PrimitiveSymbol.make("e1")), M0.make_struct_field_accessor(__ref60, 2, $rjs_core.PrimitiveSymbol.make("e2")));
var struct_arith_exp = let_result4.getAt(0);
var make_arith_exp = let_result4.getAt(1);
var arith_exp_p = let_result4.getAt(2);
var arith_exp_op = let_result4.getAt(3);
var arith_exp_e1 = let_result4.getAt(4);
var arith_exp_e2 = let_result4.getAt(5);
var let_result5 = M0.make_struct_type($rjs_core.PrimitiveSymbol.make("num-exp"), false, 1, 0, false, M0.rnull, M0.current_inspector(), false, $rjs_core.Pair.makeList(0), false, $rjs_core.PrimitiveSymbol.make("num-exp"));
var struct_62 = let_result5.getAt(0);
var make_63 = let_result5.getAt(1);
var __p64 = let_result5.getAt(2);
var __ref65 = let_result5.getAt(3);
var __set_bang_66 = let_result5.getAt(4);
var let_result6 = M0.values(struct_62, make_63, __p64, M0.make_struct_field_accessor(__ref65, 0, $rjs_core.PrimitiveSymbol.make("n")));
var struct_num_exp = let_result6.getAt(0);
var make_num_exp = let_result6.getAt(1);
var num_exp_p = let_result6.getAt(2);
var num_exp_n = let_result6.getAt(3);
var let_result7 = M0.make_struct_type($rjs_core.PrimitiveSymbol.make("var-exp"), false, 1, 0, false, M0.rnull, M0.current_inspector(), false, $rjs_core.Pair.makeList(0), false, $rjs_core.PrimitiveSymbol.make("var-exp"));
var struct_67 = let_result7.getAt(0);
var make_68 = let_result7.getAt(1);
var __p69 = let_result7.getAt(2);
var __ref70 = let_result7.getAt(3);
var __set_bang_71 = let_result7.getAt(4);
var let_result8 = M0.values(struct_67, make_68, __p69, M0.make_struct_field_accessor(__ref70, 0, $rjs_core.PrimitiveSymbol.make("i")));
var struct_var_exp = let_result8.getAt(0);
var make_var_exp = let_result8.getAt(1);
var var_exp_p = let_result8.getAt(2);
var var_exp_i = let_result8.getAt(3);
if (false !== false) {
  var exp72 = M0.rvoid;
  var error73 = M0.rvoid;
  var NUM74 = M0.rvoid;
  var VAR75 = M0.rvoid;
  var __plus_76 = M0.rvoid;
  var __77 = M0.rvoid;
  var EOF78 = M0.rvoid;
  var LET79 = M0.rvoid;
  var IN80 = M0.rvoid;
  var if_res9 = M0.rvoid(LET79, VAR75, NUM74, IN80, exp72, NUM74, VAR75, exp72, __plus_76, exp72, exp72, __77, exp72, false, false, exp72, EOF78, __77, __plus_76);
} else {
  var if_res9 = M0.rvoid();
}
if_res9;
var simple_math_parser = M3.__rjs_quoted__.parser_body(false, M0.rvoid, $rjs_core.Pair.makeList($rjs_core.PrimitiveSymbol.make("exp")), $rjs_core.Pair.makeList($rjs_core.PrimitiveSymbol.make("EOF")), $rjs_core.Vector.make([$rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("g1987"), -2],
  [$rjs_core.PrimitiveSymbol.make("VAR"), 4],
  [$rjs_core.PrimitiveSymbol.make("NUM"), 3],
  [$rjs_core.PrimitiveSymbol.make("exp"), -3],
  [$rjs_core.PrimitiveSymbol.make("LET"), 5]
], false), $rjs_core.Hash.makeEq([], false), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("EOF"), $rjs_core.PrimitiveSymbol.make("accept")],
  [$rjs_core.PrimitiveSymbol.make("+"), 6],
  [$rjs_core.PrimitiveSymbol.make("-"), 7]
], false), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("EOF"), $rjs_core.Vector.make([3, $rjs_core.PrimitiveSymbol.make("exp"), 1])],
  [$rjs_core.PrimitiveSymbol.make("+"), $rjs_core.Vector.make([3, $rjs_core.PrimitiveSymbol.make("exp"), 1])],
  [$rjs_core.PrimitiveSymbol.make("-"), $rjs_core.Vector.make([3, $rjs_core.PrimitiveSymbol.make("exp"), 1])]
], false), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("EOF"), $rjs_core.Vector.make([4, $rjs_core.PrimitiveSymbol.make("exp"), 1])],
  [$rjs_core.PrimitiveSymbol.make("+"), $rjs_core.Vector.make([4, $rjs_core.PrimitiveSymbol.make("exp"), 1])],
  [$rjs_core.PrimitiveSymbol.make("-"), $rjs_core.Vector.make([4, $rjs_core.PrimitiveSymbol.make("exp"), 1])]
], false), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("VAR"), 9]
], false), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("VAR"), 4],
  [$rjs_core.PrimitiveSymbol.make("NUM"), 3],
  [$rjs_core.PrimitiveSymbol.make("exp"), -11],
  [$rjs_core.PrimitiveSymbol.make("LET"), 5]
], false), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("VAR"), 4],
  [$rjs_core.PrimitiveSymbol.make("NUM"), 3],
  [$rjs_core.PrimitiveSymbol.make("exp"), -12],
  [$rjs_core.PrimitiveSymbol.make("LET"), 5]
], false), $rjs_core.Hash.makeEq([], false), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("NUM"), 12]
], false), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("EOF"), $rjs_core.Vector.make([5, $rjs_core.PrimitiveSymbol.make("exp"), 3])],
  [$rjs_core.PrimitiveSymbol.make("+"), $rjs_core.Vector.make([5, $rjs_core.PrimitiveSymbol.make("exp"), 3])],
  [$rjs_core.PrimitiveSymbol.make("-"), $rjs_core.Vector.make([5, $rjs_core.PrimitiveSymbol.make("exp"), 3])]
], false), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("EOF"), $rjs_core.Vector.make([6, $rjs_core.PrimitiveSymbol.make("exp"), 3])],
  [$rjs_core.PrimitiveSymbol.make("+"), $rjs_core.Vector.make([6, $rjs_core.PrimitiveSymbol.make("exp"), 3])],
  [$rjs_core.PrimitiveSymbol.make("-"), $rjs_core.Vector.make([6, $rjs_core.PrimitiveSymbol.make("exp"), 3])]
], false), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("IN"), 13]
], false), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("VAR"), 4],
  [$rjs_core.PrimitiveSymbol.make("NUM"), 3],
  [$rjs_core.PrimitiveSymbol.make("exp"), -15],
  [$rjs_core.PrimitiveSymbol.make("LET"), 5]
], false), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("EOF"), $rjs_core.Vector.make([2, $rjs_core.PrimitiveSymbol.make("exp"), 5])],
  [$rjs_core.PrimitiveSymbol.make("+"), 6],
  [$rjs_core.PrimitiveSymbol.make("-"), 7]
], false)]), $rjs_core.Hash.makeEq([
  [$rjs_core.PrimitiveSymbol.make("NUM"), true],
  [$rjs_core.PrimitiveSymbol.make("EOF"), true],
  [$rjs_core.PrimitiveSymbol.make("LET"), true],
  [$rjs_core.PrimitiveSymbol.make("-"), true],
  [$rjs_core.PrimitiveSymbol.make("VAR"), true],
  [$rjs_core.PrimitiveSymbol.make("IN"), true],
  [$rjs_core.PrimitiveSymbol.make("+"), true],
  [$rjs_core.PrimitiveSymbol.make("error"), true]
], false), M0.vector(function(x81) {
  if (arguments.length !== 1) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return x81;
}, function(x82) {
  if (arguments.length !== 1) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return x82;
}, function(g198883, $284, $385, g198986, $587) {
  if (arguments.length !== 5) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return make_let_exp($284, make_num_exp($385), $587);
}, function($188) {
  if (arguments.length !== 1) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return make_num_exp($188);
}, function($189) {
  if (arguments.length !== 1) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return make_var_exp($189);
}, function($190, g199091, $392) {
  if (arguments.length !== 3) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return make_arith_exp(M0.__plus_, $190, $392);
}, function($193, g199194, $395) {
  if (arguments.length !== 3) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return make_arith_exp(M0.__, $193, $395);
}), false);
var reval = function(_parsed_exp9682) {
  if (arguments.length !== 1) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  lambda_start77: while (true) {
    let parsed_exp96 = _parsed_exp9682;
    var parsed_exp4597 = parsed_exp96;
    var fail4698 = function() {
      if (arguments.length !== 0) {
        throw $rjs_core.racketContractError("arity mismatch");
      } else {}
      return M4.match_error(parsed_exp4597, M4.syntax_srclocs(null), $rjs_core.PrimitiveSymbol.make("match"));
    };
    var f4799 = function() {
      if (arguments.length !== 0) {
        throw $rjs_core.racketContractError("arity mismatch");
      } else {}
      if (var_exp_p(parsed_exp4597) !== false) {
        var temp48100 = (function(x101) {
          if (arguments.length !== 1) {
            throw $rjs_core.racketContractError("arity mismatch");
          } else {}
          if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
            var if_res10 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
          } else {
            var if_res10 = false;
          }
          if (if_res10 !== false) {
            return M7.unsafe_struct_ref(x101, 0);
          } else {
            return var_exp_i(x101);
          }
        })(parsed_exp4597);
        var i102 = temp48100;
        return M0.error($rjs_core.PrimitiveSymbol.make("eval"), $rjs_core.UString.make("undefined identifier ~a"), i102);
      } else {
        return fail4698();
      }
    };
    var f51103 = function() {
      if (arguments.length !== 0) {
        throw $rjs_core.racketContractError("arity mismatch");
      } else {}
      if (num_exp_p(parsed_exp4597) !== false) {
        return (function(x105) {
          if (arguments.length !== 1) {
            throw $rjs_core.racketContractError("arity mismatch");
          } else {}
          if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
            var if_res13 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
          } else {
            var if_res13 = false;
          }
          if (if_res13 !== false) {
            return M7.unsafe_struct_ref(x105, 0);
          } else {
            return num_exp_n(x105);
          }
        })(parsed_exp4597);
      } else {
        return f4799();
      }
    };
    var f55107 = function() {
      if (arguments.length !== 0) {
        throw $rjs_core.racketContractError("arity mismatch");
      } else {}
      if (arith_exp_p(parsed_exp4597) !== false) {
        var temp56108 = (function(x111) {
          if (arguments.length !== 1) {
            throw $rjs_core.racketContractError("arity mismatch");
          } else {}
          if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
            var if_res16 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
          } else {
            var if_res16 = false;
          }
          if (if_res16 !== false) {
            return M7.unsafe_struct_ref(x111, 0);
          } else {
            return arith_exp_op(x111);
          }
        })(parsed_exp4597);
        var temp57109 = (function(x112) {
          if (arguments.length !== 1) {
            throw $rjs_core.racketContractError("arity mismatch");
          } else {}
          if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
            var if_res18 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
          } else {
            var if_res18 = false;
          }
          if (if_res18 !== false) {
            return M7.unsafe_struct_ref(x112, 1);
          } else {
            return arith_exp_e1(x112);
          }
        })(parsed_exp4597);
        var temp58110 = (function(x113) {
          if (arguments.length !== 1) {
            throw $rjs_core.racketContractError("arity mismatch");
          } else {}
          if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
            var if_res20 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
          } else {
            var if_res20 = false;
          }
          if (if_res20 !== false) {
            return M7.unsafe_struct_ref(x113, 2);
          } else {
            return arith_exp_e2(x113);
          }
        })(parsed_exp4597);
        var e2114 = temp58110;
        var e1115 = temp57109;
        var op116 = temp56108;
        return op116(reval(e1115), reval(e2114));
      } else {
        return f51103();
      }
    };
    if (let_exp_p(parsed_exp4597) !== false) {
      var temp64117 = (function(x120) {
        if (arguments.length !== 1) {
          throw $rjs_core.racketContractError("arity mismatch");
        } else {}
        if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
          var if_res23 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
        } else {
          var if_res23 = false;
        }
        if (if_res23 !== false) {
          return M7.unsafe_struct_ref(x120, 0);
        } else {
          return let_exp_var(x120);
        }
      })(parsed_exp4597);
      var temp65118 = (function(x121) {
        if (arguments.length !== 1) {
          throw $rjs_core.racketContractError("arity mismatch");
        } else {}
        if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
          var if_res25 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
        } else {
          var if_res25 = false;
        }
        if (if_res25 !== false) {
          return M7.unsafe_struct_ref(x121, 1);
        } else {
          return let_exp_num(x121);
        }
      })(parsed_exp4597);
      var temp66119 = (function(x122) {
        if (arguments.length !== 1) {
          throw $rjs_core.racketContractError("arity mismatch");
        } else {}
        if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
          var if_res27 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
        } else {
          var if_res27 = false;
        }
        if (if_res27 !== false) {
          return M7.unsafe_struct_ref(x122, 2);
        } else {
          return let_exp_exp(x122);
        }
      })(parsed_exp4597);
      var exp123 = temp66119;
      var num124 = temp65118;
      var var125 = temp64117;
      _parsed_exp9682 = subst(var125, num124, exp123);
      continue lambda_start77;
    } else {
      return f55107();
    }
  }
};
var subst = function(var126, num127, exp128) {
  if (arguments.length !== 3) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  var exp75129 = exp128;
  var fail76130 = function() {
    if (arguments.length !== 0) {
      throw $rjs_core.racketContractError("arity mismatch");
    } else {}
    return M4.match_error(exp75129, M4.syntax_srclocs(null), $rjs_core.PrimitiveSymbol.make("match"));
  };
  var f77131 = function() {
    if (arguments.length !== 0) {
      throw $rjs_core.racketContractError("arity mismatch");
    } else {}
    if (num_exp_p(exp75129) !== false) {
      var temp78132 = (function(x133) {
        if (arguments.length !== 1) {
          throw $rjs_core.racketContractError("arity mismatch");
        } else {}
        if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
          var if_res30 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
        } else {
          var if_res30 = false;
        }
        if (if_res30 !== false) {
          return M7.unsafe_struct_ref(x133, 0);
        } else {
          return num_exp_n(x133);
        }
      })(exp75129);
      var n134 = temp78132;
      return exp128;
    } else {
      return fail76130();
    }
  };
  var f81135 = function() {
    if (arguments.length !== 0) {
      throw $rjs_core.racketContractError("arity mismatch");
    } else {}
    if (var_exp_p(exp75129) !== false) {
      var temp82136 = (function(x137) {
        if (arguments.length !== 1) {
          throw $rjs_core.racketContractError("arity mismatch");
        } else {}
        if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
          var if_res33 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
        } else {
          var if_res33 = false;
        }
        if (if_res33 !== false) {
          return M7.unsafe_struct_ref(x137, 0);
        } else {
          return var_exp_i(x137);
        }
      })(exp75129);
      var id138 = temp82136;
      if (M0.equal_p(id138, var126) !== false) {
        return num127;
      } else {
        return exp128;
      }
    } else {
      return f77131();
    }
  };
  var f85139 = function() {
    if (arguments.length !== 0) {
      throw $rjs_core.racketContractError("arity mismatch");
    } else {}
    if (arith_exp_p(exp75129) !== false) {
      var temp86140 = (function(x143) {
        if (arguments.length !== 1) {
          throw $rjs_core.racketContractError("arity mismatch");
        } else {}
        if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
          var if_res37 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
        } else {
          var if_res37 = false;
        }
        if (if_res37 !== false) {
          return M7.unsafe_struct_ref(x143, 0);
        } else {
          return arith_exp_op(x143);
        }
      })(exp75129);
      var temp87141 = (function(x144) {
        if (arguments.length !== 1) {
          throw $rjs_core.racketContractError("arity mismatch");
        } else {}
        if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
          var if_res39 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
        } else {
          var if_res39 = false;
        }
        if (if_res39 !== false) {
          return M7.unsafe_struct_ref(x144, 1);
        } else {
          return arith_exp_e1(x144);
        }
      })(exp75129);
      var temp88142 = (function(x145) {
        if (arguments.length !== 1) {
          throw $rjs_core.racketContractError("arity mismatch");
        } else {}
        if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
          var if_res41 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
        } else {
          var if_res41 = false;
        }
        if (if_res41 !== false) {
          return M7.unsafe_struct_ref(x145, 2);
        } else {
          return arith_exp_e2(x145);
        }
      })(exp75129);
      var e2146 = temp88142;
      var e1147 = temp87141;
      var op148 = temp86140;
      return make_arith_exp(op148, subst(var126, num127, e1147), subst(var126, num127, e2146));
    } else {
      return f81135();
    }
  };
  if (let_exp_p(exp75129) !== false) {
    var temp94149 = (function(x152) {
      if (arguments.length !== 1) {
        throw $rjs_core.racketContractError("arity mismatch");
      } else {}
      if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
        var if_res44 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
      } else {
        var if_res44 = false;
      }
      if (if_res44 !== false) {
        return M7.unsafe_struct_ref(x152, 0);
      } else {
        return let_exp_var(x152);
      }
    })(exp75129);
    var temp95150 = (function(x153) {
      if (arguments.length !== 1) {
        throw $rjs_core.racketContractError("arity mismatch");
      } else {}
      if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
        var if_res46 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
      } else {
        var if_res46 = false;
      }
      if (if_res46 !== false) {
        return M7.unsafe_struct_ref(x153, 1);
      } else {
        return let_exp_num(x153);
      }
    })(exp75129);
    var temp96151 = (function(x154) {
      if (arguments.length !== 1) {
        throw $rjs_core.racketContractError("arity mismatch");
      } else {}
      if (M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference")) !== false) {
        var if_res48 = M0.variable_reference_constant_p($rjs_core.PrimitiveSymbol.make("#%variable-reference"));
      } else {
        var if_res48 = false;
      }
      if (if_res48 !== false) {
        return M7.unsafe_struct_ref(x154, 2);
      } else {
        return let_exp_exp(x154);
      }
    })(exp75129);
    var exp2155 = temp96151;
    var num2156 = temp95150;
    var var2157 = temp94149;
    if (M0.eq_p(var126, var2157) !== false) {
      return exp128;
    } else {
      return make_let_exp(var2157, num2156, subst(var126, num127, exp2155));
    }
  } else {
    return f85139();
  }
};
var lex_this = function(lexer158, input159) {
  if (arguments.length !== 2) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  return function() {
    if (arguments.length !== 0) {
      throw $rjs_core.racketContractError("arity mismatch");
    } else {}
    return lexer158(input159);
  };
};
M0.call_with_values(function() {
  if (arguments.length !== 0) {
    throw $rjs_core.racketContractError("arity mismatch");
  } else {}
  var input160 = M0.open_input_string($rjs_core.UString.make("3 - 3.3 + 6"));
  return M2.displayln(simple_math_parser(lex_this(simple_math_lexer, input160)));
}, M5.__rjs_quoted__.print_values);
var __rjs_quoted__ = {};
__rjs_quoted__.let_exp_exp = let_exp_exp;
__rjs_quoted__.make_var_exp = make_var_exp;
__rjs_quoted__.arith_exp_p = arith_exp_p;
__rjs_quoted__.var_exp_i = var_exp_i;
__rjs_quoted__.let_exp_p = let_exp_p;
__rjs_quoted__.var_exp_p = var_exp_p;
__rjs_quoted__.struct_num_exp = struct_num_exp;
__rjs_quoted__.make_arith_exp = make_arith_exp;
__rjs_quoted__.let_exp_num = let_exp_num;
__rjs_quoted__.struct_var_exp = struct_var_exp;
__rjs_quoted__.arith_exp_op = arith_exp_op;
__rjs_quoted__.make_num_exp = make_num_exp;
__rjs_quoted__.struct_let_exp = struct_let_exp;
__rjs_quoted__.let_exp_var = let_exp_var;
__rjs_quoted__.make_let_exp = make_let_exp;
__rjs_quoted__.num_exp_p = num_exp_p;
__rjs_quoted__.arith_exp_e2 = arith_exp_e2;
__rjs_quoted__.arith_exp_e1 = arith_exp_e1;
__rjs_quoted__.num_exp_n = num_exp_n;
__rjs_quoted__.struct_arith_exp = struct_arith_exp;
export {
  __rjs_quoted__,
  let_exp_var,
  var_exp_p,
  token_LET,
  let_exp_num,
  num_exp_n,
  let_exp_p,
  arith_exp_p,
  reval,
  num_exp_p,
  token_IN,
  var_exp_i,
  arith_exp_op,
  arith_exp_e1,
  simple_math_lexer,
  make_let_exp,
  struct_let_exp,
  arith_exp_e2,
  token_NUM,
  make_num_exp,
  simple_math_parser,
  token_VAR,
  struct_arith_exp,
  lex_this,
  let_exp_exp,
  make_arith_exp,
  struct_var_exp,
  token__plus_,
  struct_num_exp,
  token_EOF,
  subst,
  make_var_exp,
  token__
};