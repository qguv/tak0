module patches::simplify_triple_negation
import js2;

Source simplify_triple_negation(Source unit) = innermost visit(unit) {
    case
        (Expression) `!!!<Expression e>` =>
        (Expression) `!<Expression e>`
};
