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

data Codebase
    = codebasePath(loc path)
    | codebaseString(str src)
    | codebaseAST(Source source);

alias Patch = Source(Source);
alias Branch = list[Patch];
alias Merge = tuple[Codebase, list[Branch]];
list[Merge] testcases = [
    <codebasePath(|home:///dev/tak/test/ternary.js|), [[flip_negative_condition], [remove_ternary_with_boolean_literal_branches]]>,
    <codebasePath(|home:///dev/tak/test/ternary.js|), [[flip_negative_condition], [remove_ternary_with_boolean_literal_branches], [simplify_triple_negation]]>,
    <codebasePath(|home:///dev/tak/test/boolean1.js|), [[remove_conjunction], [remove_disjunction]]>,
    <codebasePath(|home:///dev/tak/test/boolean2.js|), [[remove_conjunction], [remove_disjunction]]>
    //<codebasePath(|home:///dev/tak/test/case02.js|), [[case02a], [case02b]]>
];
str letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

Source parseCodebase(Codebase codebase) {
    switch (codebase) {
        case codebasePath(src_path): {
            println("\n== <src_path.file> ==");
            return parseCodebase(codebaseString(readFile(src_path)));
        }
        case codebaseString(s): {
            return parseCodebase(codebaseAST(parse(#Source, trim(s))));
        }
        case codebaseAST(n): {
            println(n);
            return n;
        }
    }
    return parse(#Source, "");
}

void main(list[str] args) {

    // to increase verbosity to 4, use -vvvv or -v -v -v -v (or a combination)
    int verbosity = sum([size(arg) - 1 | arg <- args, startsWith(arg, "-v")] + [0]);

    for (<codebase, changes> <- testcases) {
        map[Source, list[str]] results = ();

        try {
            Source src_ast = parseCodebase(codebase);

            int num_permutations = 0;
            for (permutation <- permutations([0..size(changes)])) {
                num_permutations += 1;

                Source result = src_ast;
                str permutation_name = "";
                for (i <- permutation) {
                    permutation_name += letters[i];

                    for (j <- [0..size(changes[i])]) {
                        change = changes[i][j];
                        result = change(result);
                        if (1 < verbosity) {
                            println("\n-- <permutation_name> --\n<result>");
                        }
                    }
                }
                if (verbosity == 1) {
                    println("\n-- <permutation_name> --\n<result>");
                }

                if (result in results) {
                    results[result] += [permutation_name];
                } else {
                    results[result] = [permutation_name];
                }

                // TODO: idempotence
            }

            println("\n-- results --");
            str trivial = (
                src_ast in results ? (
                    size(results) == 1 ? "always"
                    : "sometimes"
                )
                : "never"
            );
            println("trivial?  <trivial>");
            println("commutes? <
                trivial == "always" ? "yes (trivially)"
                : size(results) == 1 ? "yes"
                : "no (<intercalate(" != ", [intercalate("/", results[r]) | r <- results])>)"
            >");

        } catch ParseError(loc l): {
            println("I found a parse error at line <l.begin.line>, column <l.begin.column>");
            return;
        }
    }
}
