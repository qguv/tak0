module Main

extend Exception; // ParseError
import flip_negative_condition;
import remove_ternary_with_boolean_literal_branches;
import simplify_triple_negation;
import remove_conjunction;
import remove_disjunction;
import case02a;
import case02b;
import IO; // readFile, println
import js2;
import ParseTree; // parse
import String; // trim, size
import Map; // size
import Node; // toString
import util::FileSystem;

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
            return parseCodebase(codebase);
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

    int num_permutations = 0;
    for (permutation <- permutations([0..size(merge.branches)])) {
        num_permutations += 1;

        AST result = merge.base;
        str permutation_name = "";
        for (i <- permutation) {
            permutation_name += letters[i];

            for (j <- [0..size(merge.branches[i])]) {
                change = merge.branches[i][j];
                result = change(result);
                if (2 < verbosity) {
                    println("\n-- <permutation_name> --\n<result>");
                }
            }
        }
        if (verbosity == 3) {
            println("\n-- <permutation_name> --\n<result>");
        }

        if (result in results) {
            results[result] += [permutation_name];
        } else {
            results[result] = [permutation_name];
        }

    }
    return results;
}

str plural(str s, list[value] xs) {
    return size(xs) == 1 ? s : "<s>s";
}

void main(list[str] args) {

    // to increase verbosity to 4, use -vvvv or -v -v -v -v (or a combination)
    int verbosity = (0 | it + size(arg) - 1 | arg <- args, startsWith(arg, "-v"));

    int test_i = 0;
    for (<case_name, base_codebase, branches> <- testcases) {
        println("\n== test #<test_i>: <case_name> ==");
        test_i += 1;

        try {
            AST base = parseCodebase(base_codebase, verbosity=verbosity);

            map[AST, list[str]] results = commute(<base, branches>, verbosity=verbosity);

            // TODO: idempotence

            if (1 < verbosity) {
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
                : "no (<intercalate(" != ", sort([intercalate("/", results[r]) | r <- results]))>)"
            >");

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

        } catch ParseError(loc l): {
            println("javascript parse error in <l>\n  line <l.begin.line>, column <l.begin.column>");
        }
    }
}
