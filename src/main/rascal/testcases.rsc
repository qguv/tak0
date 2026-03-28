module testcases

import patches::flip_negative_condition;
import patches::remove_ternary_with_boolean_literal_branches;
import patches::simplify_triple_negation;
import patches::remove_conjunction;
import patches::remove_disjunction;
//import patches::case02a;
//import patches::case02b;
import vctypes;
import deeper::codebase;

alias Testcase = tuple[str name, Codebase codebase, list[Branch] branches];
public list[Testcase] commuteTests = [
    //<"test linter-style rules", codebasePath(|home:///dev/tak/test/case02.js|), [[case02a], [case02b]]>,
    <
        "some binary merges are trivial",
        codebasePath(|home:///dev/tak/test/boolean0.js|),
        [
            [remove_conjunction],
            [remove_disjunction]
        ]
    >,
    <
        "some non-trivial binary merges commute",
        codebasePath(|home:///dev/tak/test/boolean1.js|),
        [
            [remove_conjunction],
            [remove_disjunction]
        ]
    >,
    <
        "other binary merges don\'t commute (1)",
        codebasePath(|home:///dev/tak/test/boolean2.js|),
        [
            [remove_conjunction],
            [remove_disjunction]
        ]
    >,
    <
        "other binary merges don\'t commute (2)",
        codebasePath(|home:///dev/tak/test/ternary.js|),
        [
            [flip_negative_condition],
            [remove_ternary_with_boolean_literal_branches]
        ]
    >,
    <
        "some ternary merges don\'t commute",
        codebasePath(|home:///dev/tak/test/ternary.js|),
        [
            [flip_negative_condition],
            [remove_ternary_with_boolean_literal_branches],
            [simplify_triple_negation]
        ]
    >
];
