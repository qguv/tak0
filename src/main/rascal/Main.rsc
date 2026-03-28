module Main

import display;
import js2;
import patches::case02a;
import patches::case02b;
import patches::flip_negative_condition;
import patches::remove_conjunction;
import patches::remove_disjunction;
import patches::remove_ternary_with_boolean_literal_branches;
import patches::simplify_triple_negation;

extend Exception; // ParseError

import IO; // readFile, println, getResource
import Map; // size
import Node; // toString
import ParseTree; // parse
import Set; // sort, getFirstFrom
import String; // trim, size, intercalate

alias AST = Source;
alias Patch = AST(AST);
alias Branch = list[Patch];
alias Merge = tuple[AST base, list[Branch] branches];

data Codebase
    = codebasePath(loc path)
    | codebaseString(str src)
    | codebaseAST(AST source);

alias Testcase = tuple[str name, Codebase codebase, list[Branch] branches];

list[Testcase] testcases = [
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
str letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

str strip_multiline_comments(str s) {
    while (/^<left:.*>\/\*.*\*\/<right:.*>$/s := s) {
        s = left + right;
    }
    return s;
}

AST parseCodebase(Codebase codebase, int verbosity=0) {
    switch (codebase) {
        case codebasePath(src_path): {
            if (verbosity > 1) {
                println("\n-- <src_path.file> --");
            }
            return parseCodebase(codebaseString(readFile(src_path)), verbosity=verbosity);
        }
        case codebaseString(s): {
            s = strip_multiline_comments(s);
            s = trim(s);
            AST ast = parse(#AST, trim(s));
            Codebase codebase = codebaseAST(ast);
            return parseCodebase(codebase, verbosity=verbosity);
        }
        case codebaseAST(n): {
            if (verbosity > 1) {
                println(n);
            }
            return n;
        }
    }
    return parse(#AST, "");
}

map[AST, list[str]] commute(Merge merge, int verbosity = 0) {
    map[AST, list[str]] results = ();

    // go through each permutation of the branches
    int num_permutations = 0;
    for (branch_order <- sort(permutations([0..size(merge.branches)]))) {
        num_permutations += 1;

        if (1 < verbosity) {
            println("\n-- permutation <intercalate("", [letters[branch_i] | branch_i <- branch_order])> --");
        }

        // apply each branch in the permuted order
        AST result = merge.base;
        list[str] permutation_name = [];
        int last_branch_i = last(branch_order);
        for (branch_i <- branch_order) {
            Branch branch = merge.branches[branch_i];
            permutation_name += [letters[branch_i]];

            if (2 < verbosity) {
                println("\n  :: branch <intercalate(", then branch ", permutation_name)> ::");
            }

            // apply all patches on this branch, in order
            for (patch_i <- [0..size(branch)]) {
                Patch patch = branch[patch_i];
                result = patch(result);

                if (3 < verbosity) {
                    println("\n    .. patch <patch_i> ..\n<indent("    ", unparse(result))>");
                }
            }

            if (verbosity == 3) {
                println("<indent("  ", unparse(result))>");
            }
        }

        if (verbosity == 2) {
            println(result);
        }

        if (result in results) {
            results[result] += [intercalate("", permutation_name)];
        } else {
            results[result] = [intercalate("", permutation_name)];
        }

    }
    return results;
}

str plural(str s, list[value] xs) {
    return size(xs) == 1 ? s : "<s>s";
}

void demo(int verbosity=0) {

    int test_i = 0;
    for (<case_name, base_codebase, branches> <- testcases) {
        println("\n== test #<test_i>: <case_name> ==");
        test_i += 1;

        try {
            AST base = parseCodebase(base_codebase, verbosity=verbosity);

            map[AST, list[str]] results = commute(<base, branches>, verbosity=verbosity);

            // TODO: idempotence

            if (verbosity == 1) {

                map[AST, str] results_formatted = (
                    ast: "permutation " + intercalate("/", sort(results[ast]))
                    | ast <- results
                );

                str base_name = "base";
                if (base in results_formatted) {
                    base_name += " & " + results_formatted[base];
                    results_formatted = delete(results_formatted, base);
                }

                for (<result, result_name> <- [<base, base_name>] + sort(toList(results_formatted))) {
                    println("\n-- <result_name> --\n<result>");
                }
            }

            if (0 < verbosity) {
                println("\n-- results --");
            }

            str trivial = (
                base in results ? (
                    size(results) == 1 ? "always"
                    : "sometimes"
                )
                : "never"
            );
            println("trivial?  <trivial>");
            println("commutes? <
                trivial == "always" ? "yes (trivially)"
                : size(results) == 1 ? "yes"
                : "no (<intercalate(" != ", sort([intercalate("/", sort(results[r])) | r <- results]))>)"
            >");

        } catch ParseError(loc l): {
            println("javascript parse error in <l>\n  line <l.begin.line>, column <l.begin.column>");
        }
    }
}

/*
    verbosity: pass multiple `-v` flags on the command line to increase verbosity. you can also use a repeated `-vv...`. for example, `-v -vv` and `-vvv` both set verbosity to 3

    levels:

    0. just show the properties of each merge
    1. show each *unique* output generated by one or more permutations, labelled with the permutation(s) that generated it, followed by the results
    2. show each permutation and its output in order, followed by the results
    3. as above, but also show the intermediate state after applying each branch in a permutation
    4. as above, but also show the intermediate states after applying each patch in a branch
*/
int get_verbosity(list[str] args) {
    return (0 | it + size(arg) - 1 | arg <- args, startsWith(arg, "-v"));
}

void main(list[str] args) {
    int verbosity = get_verbosity(args);
    demo(verbosity=verbosity);
}
