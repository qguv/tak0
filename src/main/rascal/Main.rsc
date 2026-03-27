module Main

extend Exception; // ParseError
import case01;
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
    <|home:///dev/tak/test/case01.js|, [case01]>,
    <|home:///dev/tak/test/case02.js|, [case02a, case02b]>
];
str letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

void main(list[str] _) {
    for (<src_path, changes> <- testcases) {

        println("\n<src_path.file>\n");
        str src = readFile(src_path);
        src = trim(src);
        println(src);

        try {
            Source src_ast = parse(#Source, src);
            println("\n-----------------\nAST:\n<src_ast>\n");

            for (permutation <- permutations([0..size(changes)])) {
                Source new_ast = src_ast;
                str hist = "";

                for (i <- change_indexes) {
                    hist += letters[i];
                    Change = changes[i];
                    new_ast = change(new_ast);
                    println("\nAST <hist>:\n<new_ast>\n");
                }
            }

        } catch ParseError(loc l): {
            println("I found a parse error at line <l.begin.line>, column <l.begin.column>");
            return;
        }
    }
}
