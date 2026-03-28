// adapted from https://www.rascal-mpl.org/docs/WhyRascal/UseCases/SourceToSource/
module patches::flip_negative_condition
import js2;

Source flip_negative_condition(Source unit) = innermost visit(unit) {
    case
        (Expression) `!<Expression cond> ? <Expression a> : <Expression b>` =>
        (Expression) `<Expression cond> ? <Expression b> : <Expression a>`
    case
        (Statement) `if (!<Expression cond>) { <Statement a> } else { <Statement b> }` =>
        (Statement) `if (<Expression cond>) { <Statement b> } else { <Statement a> }`
};
