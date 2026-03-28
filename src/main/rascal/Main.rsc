module Main

extend Exception; // ParseError
import flip_negative_condition;
import remove_ternary_with_boolean_literal_branches;
import simplify_triple_negation;
import case02a;
import case02b;
import IO; // readFile, println
import js2;
import ParseTree; // parse
import String; // trim, size
import Map; // size
import util::FileSystem;

alias Change = Source(Source);
alias Testcase = tuple[loc, list[Change]];
list[Testcase] testcases = [
    <|home:///dev/tak/test/ternary.js|, [flip_negative_condition, remove_ternary_with_boolean_literal_branches]>,
    <|home:///dev/tak/test/ternary.js|, [flip_negative_condition, remove_ternary_with_boolean_literal_branches, simplify_triple_negation]>
    //<|home:///dev/tak/test/case02.js|, [case02a, case02b]>
];
str letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

void main(list[str] args) {

    // to increase verbosity to 4, use -vvvv or -v -v -v -v (or a combination)
    int verbosity = sum([size(arg) - 1 | arg <- args, startsWith(arg, "-v")] + [0]);

    for (<src_path, changes> <- testcases) {
        map[Source, list[str]] results = [];

        println("\n== <src_path.file> ==");
        str src = readFile(src_path);
        src = trim(src);

        try {
            Source src_ast = parse(#Source, src);
            println("<src_ast>");

            int num_permutations = 0;
            for (permutation <- permutations([0..size(changes)])) {
                num_permutations += 1;

                Source result = src_ast;
                str permutation_name = "";
                for (i <- permutation) {
                    permutation_name += letters[i];
                    change = changes[i];
                    result = change(result);
                    if (1 < verbosity) {
                        println("\n-- <permutation_name> --\n<result>");
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
            }

            println("\n-- results --");
            str trivial = (
                !(src_ast in results) ? "never"
                : size(results) == 1 ? "always"
                : "sometimes"
            );
            println("trivial?  <trivial>");
            println("commutes? <
                trivial == "always" ? "yes (trivially)"
                : size(results) == 1 ? "yes"
                : "no (<intercalate(" != ", [intercalate("/", results[r]) | r <- results])>"
            >");

        } catch ParseError(loc l): {
            println("I found a parse error at line <l.begin.line>, column <l.begin.column>");
            return;
        }
    }
}
