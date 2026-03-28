module patches::case02a

import deeper::js2;

Source case02a(Source unit) = innermost visit(unit) {

   // add brackets to "then" block
    case
        (Statement) `if (<Expression cond>) <Statement a>` =>
        (Statement) `if (<Expression cond>) { <Statement a> }` 
        when
            (Statement) `{ <Statement _> }` !:= a

   // add brackets to "else" block
    case
        (Statement) `if (<Expression cond>) <Statement a> else <Statement b>` =>   
        (Statement) `if (<Expression cond>) <Statement a> else { <Statement b> }` 
        when
            (Statement) `{ <Statement _> }` !:= b

    // remove unnecessary bools

    case
        (Statement) `if (<Expression cond> === true) { <Statement a> }` =>
        (Statement) `if (<Expression cond>) { <Statement a> }`

    case
        (Statement) `if (<Expression cond> === true) { <Statement a> } else { <Statement b> }` =>
        (Statement) `if (<Expression cond>) { <Statement a> } else { <Statement b> }`

    case
        (Statement) `if (<Expression cond> === false) { <Statement a> }` =>
        (Statement) `if (!<Expression cond>) { <Statement a> }`

    case
        (Statement) `if (<Expression cond> === false) { <Statement a> } else { <Statement b> }` =>
        (Statement) `if (!<Expression cond>) { <Statement a> } else { <Statement b> }`

    case
        (Expression) `<Expression cond> == true ? <Expression a> : <Expression b>` =>
        (Expression) `<Expression cond> ? <Expression a> : <Expression b>`

    case
        (Expression) `<Expression cond> == false ? <Expression a> : <Expression b>` =>
        (Expression) `!<Expression cond> ? <Expression a> : <Expression b>`

    case
        (Expression) `<Expression cond> ? true : false` =>
        (Expression) `<Expression cond>`

    case
        (Expression) `<Expression cond> ? false : true` =>
        (Expression) `!<Expression cond>`

    case
        (Statement) `if (<Expression cond>) { return true; } else { return false; }` =>
        (Statement) `return <Expression cond>;`

    case
        (Statement) `if (<Expression cond>) { return false; } else { return true; }` =>
        (Statement) `return !<Expression cond>;`

    // swap "then" and "else" blocks
    case
        (Statement) `if (!<Expression cond>) { <Statement a> } else { <Statement b> }` =>
        (Statement) `if (<Expression cond>) { <Statement b> } else { <Statement a> }`

    case
        (Expression) `!<Expression cond> ? <Expression a> : <Expression b>` =>
        (Expression) `<Expression cond> ? <Expression b> : <Expression a>`
};
