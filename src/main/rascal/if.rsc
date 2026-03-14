module \if

import lang::javascript::saner::Syntax;

Source change(Source unit) = innermost visit(unit) {

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

    /*
    case
        (Statement) `<Expression cond> == true ? <Statement a> : <Statement b>` =>
        (Statement) `<Expression cond> ? <Statement a> : <Statement b>`

    case
        (Expression) `<Expression cond> == false ? <Statement a> : <Statement b>` =>
        (Expression) `!<Expression cond> ? <Statement a> : <Statement b>`

    case
        (Expression) `<Expression cond> ? true : false` =>
        (Expression) `<Expression cond>`

    case
        (Expression) `<Expression cond> ? false : true` =>
        (Expression) `!<Expression cond>`
    */

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

    /*
    case
        (Expression) `!<Expression cond> ? <Statement a> : <Statement b>` =>
        (Expression) `<Expression cond> ? <Statement b> : <Statement a>`
    */
};
