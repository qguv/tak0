module remove_ternary_with_boolean_literal_branches
import js2;

Source remove_ternary_with_boolean_literal_branches(Source unit) = innermost visit(unit) {
    case
        (Expression) `<Expression e> ? false : true` =>
        (Expression) `!(<Expression e>)`
    case
        (Expression) `<Expression e> ? true : false` =>
        (Expression) `!!(<Expression e>)`

};
