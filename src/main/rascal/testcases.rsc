module testcases

import codebase;
import patches::flip_negative_condition;
import patches::remove_conjunction;
import patches::remove_disjunction;
import patches::remove_ternary_with_boolean_literal_branches;
import patches::simplify_triple_negation;
import vctypes;

import IO; // getResource

alias Testcase = tuple[str name, Codebase codebase, list[Branch] branches];

list[Testcase] getTestcases() = [
    //<"test linter-style rules", codebasePath(|home:///dev/tak/test/case02.js|), [[case02a], [case02b]]>,
    <
        "some binary merges are trivial",
        codebasePath(getResource("bases/boolean0.js")),
        [
            [remove_conjunction],
            [remove_disjunction]
        ]
    >,
    <
        "some non-trivial binary merges commute",
        codebasePath(getResource("bases/boolean1.js")),
        [
            [remove_conjunction],
            [remove_disjunction]
        ]
    >,
    <
        "other binary merges don\'t commute (1)",
        codebasePath(getResource("bases/boolean2.js")),
        [
            [remove_conjunction],
            [remove_disjunction]
        ]
    >,
    <
        "other binary merges don\'t commute (2)",
        codebasePath(getResource("bases/ternary.js")),
        [
            [flip_negative_condition],
            [remove_ternary_with_boolean_literal_branches]
        ]
    >,
    <
        "some ternary merges don\'t commute",
        codebasePath(getResource("bases/ternary.js")),
        [
            [flip_negative_condition],
            [remove_ternary_with_boolean_literal_branches],
            [simplify_triple_negation]
        ]
    >
];
