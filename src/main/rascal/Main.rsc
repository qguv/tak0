module Main

extend Exception; // ParseError
import \if;
import IO; // readFile, println
import lang::javascript::saner::Syntax;
import ParseTree; // parse
import String; // trim
import util::FileSystem;

void main() {
    str src = readFile(|home:///dev/tak/test/if.js|);
    println(src);
    try {
        Source ast = parse(#Source, trim(src));
        println(ast);
        Source new_ast = \if::change(ast);
        println(new_ast);
    } catch ParseError(loc l): {
        println("I found a parse error at line <l.begin.line>, column <l.begin.column>");
        return;
    }
}
