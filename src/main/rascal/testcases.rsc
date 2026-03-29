module testcases

import codebase;
import patches::add_log_general;
import patches::add_log_specific;
import patches::flip_negative_condition;
import patches::remove_conjunction;
import patches::remove_disjunction;
import patches::remove_ternary_with_boolean_literal_branches;
import patches::remove_parentheses_around_literal;
import patches::simplify_triple_negation;
import vctypes;

import IO; // getResource

data VCProperty
    = propCommutes(list[Branch] branches)
    | propFixedPoint(Branch branch, int maxAttempts=4);

alias Testcase = tuple[
    str name,
    Codebase codebase,
    VCProperty prop
];

list[Testcase] getTestcases() = [
    //<"test linter-style rules", codebasePath(|home:///dev/tak/test/case02.js|), [[case02a], [case02b]]>,
    <
        "some binary merges are trivial",
        codebasePath(getResource("bases/boolean0.js")),
        propCommutes([
            [remove_conjunction],
            [remove_disjunction]
        ])
    >,
    <
        "some non-trivial binary merges commute",
        codebasePath(getResource("bases/boolean1.js")),
        propCommutes([
            [remove_conjunction],
            [remove_disjunction]
        ])
    >,
    <
        "other binary merges don\'t commute (1)",
        codebasePath(getResource("bases/boolean2.js")),
        propCommutes([
            [remove_conjunction],
            [remove_disjunction]
        ])
    >,
    <
        "other binary merges don\'t commute (2)",
        codebasePath(getResource("bases/ternary.js")),
        propCommutes([
            [flip_negative_condition],
            [remove_ternary_with_boolean_literal_branches]
        ])
    >,
    <
        "some ternary merges don\'t commute",
        codebasePath(getResource("bases/ternary.js")),
        propCommutes([
            [flip_negative_condition],
            [remove_ternary_with_boolean_literal_branches],
            [simplify_triple_negation]
        ])
    >,
    <
        "all trivial patches for a base are trivially idempotent",
        codebasePath(getResource("bases/function2.js")),
        propFixedPoint([add_log_specific])
    >,
    <
        "some additive patches are idempotent",
        codebasePath(getResource("bases/function.js")),
        propFixedPoint([add_log_specific])
    >,
    <
        "but most additive patches are not idempotent",
        codebasePath(getResource("bases/function.js")),
        propFixedPoint([add_log_general])
    >,
    <
        "some patches can take some time before reaching a fixed point",
        codebasePath(getResource("bases/nested.js")),
        propFixedPoint([remove_disjunction, remove_conjunction, remove_parentheses_around_literal], maxAttempts=5)
    >
];
