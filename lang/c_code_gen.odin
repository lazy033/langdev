package lang

import "core:fmt"
import "core:os"
import "core:strings"

b_include: strings.Builder
b_main: strings.Builder

transpile_expr :: proc(expr: Expr) {
	switch type in expr.type {
		case ScopeExpr:
			assert(true, "Not implemented yet")
		case FnCallExpr:
 			transpile_fn_call(type);
		case LiteralStrExpr:
			assert(true, "Not implemented yet")
	}
}

transpile_fn_call :: proc(expr: FnCallExpr) {
	if expr.id.repr == "println" {
		//fixme: this will include stdio every time we call println
		strings.write_string(&b_include, "#include <stdio.h>\n")
		assert(len(expr.args) == 1, "println only accepts one argument of type str lit")
		str_lit := expr.args[0].type.(LiteralStrExpr)
		strings.write_string(&b_main, fmt.tprintf("    printf(\"{}\\n\");\n", str_lit.repr.repr))
	}
}

c_code_gen :: proc(top_level: ScopeExpr) {

	b_main = strings.builder_make()
	b_include = strings.builder_make()

	strings.write_string(&b_main, "int main(void) {\n");

	for expr in top_level.exprs {
		transpile_expr(expr)
	}

	strings.write_string(&b_main, "}\n");
	
	fmt.printf("{}\n{}", strings.to_string(b_include), strings.to_string(b_main))
}
