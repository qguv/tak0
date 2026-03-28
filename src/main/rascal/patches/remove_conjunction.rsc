module patches::remove_conjunction

import js2;

Source remove_conjunction(Source unit) = innermost visit(unit) {
    case
        (Expression) `true && <Expression a>` => a
    case
        (Expression) `false && <Expression _>` =>
        (Expression) `false`
};
