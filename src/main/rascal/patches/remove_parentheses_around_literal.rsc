module patches::remove_parentheses_around_literal

import js2;

Source remove_parentheses_around_literal(Source unit) = innermost visit(unit) {
    case
        (Expression) `(true)` => (Expression) `true`
    case
        (Expression) `(false)` => (Expression) `false`
};
