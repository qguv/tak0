module patches::remove_disjunction

import js2;

Source remove_disjunction(Source unit) = innermost visit(unit) {
    case
        (Expression) `false || <Expression a>` => a
    case
        (Expression) `true || <Expression _>` =>
        (Expression) `true`
};
