module Main

extend Exception; // ParseError
import flip_negative_condition;
import remove_ternary_with_boolean_literal_branches;
import case02a;
import case02b;
import IO; // readFile, println
import js2;
import ParseTree; // parse
import String; // trim
import util::FileSystem;

alias Change = Source(Source);
alias Testcase = tuple[loc, list[Change]];
list[Testcase] testcases = [
    <|home:///dev/tak/test/case01.js|, [flip_negative_condition, remove_ternary_with_boolean_literal_branches]>,
    <|home:///dev/tak/test/case02.js|, [case02a, case02b]>
];
str letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

void main(list[str] args) {

    // to increase verbosity to 4, use -vvvv or -v -v -v -v (or a combination)
    int verbosity = sum([size(arg) - 1 | arg <- args, startsWith(arg, "-v")] + [0]);

    for (<src_path, changes> <- testcases) {

        println("\n== <src_path.file> ==");
        str src = readFile(src_path);
        src = trim(src);

        try {
            Source src_ast = parse(#Source, src);
            println("<src_ast>");

            list[tuple[str name, Source ast]] noncommuting = [];
            list[tuple[str name, Source ast]] nontrivial = [];

            Source first_result = src_ast; // dummy value
            str first_permutation_name = ""; // dummy value
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

                // trivial?
                if (result != src_ast) {
                    nontrivial += <permutation_name, result>;
                }

                // commutes?
                if (first_permutation_name == "") {
                    first_permutation_name = permutation_name;
                    first_result = result;
                } else if (result != first_result) {
                    noncommuting += <permutation_name, result>;
                }
            }

            println("\n-- results --");
            println("trivial?  <
                isEmpty(nontrivial) ? "always"
                : size(nontrivial) == num_permutations - 1 ? "never"
                : "sometimes"
            >");
            println("commutes? <
                isEmpty(nontrivial) ? "yes (trivially)"
                : isEmpty(noncommuting) ? "yes"
                : "no (<first_permutation_name> differs from <intercalate(", ", [r.name | r <- noncommuting])>)"
            >");

        } catch ParseError(loc l): {
            println("I found a parse error at line <l.begin.line>, column <l.begin.column>");
            return;
        }
    }
}
