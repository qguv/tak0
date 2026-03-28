module codebase

import js2;
import vctypes;

import IO; // println, readFile
import String; // trim
import ParseTree; // parse

data Codebase
    = codebasePath(loc path)
    | codebaseString(str src)
    | codebaseAST(AST source);

str strip_multiline_comments(str s) {
    while (/^<left:.*>\/\*.*\*\/<right:.*>$/s := s) {
        s = left + right;
    }
    return s;
}

AST parseCodebase(Codebase cb, int verbosity=0) {
    switch (cb) {
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
            Codebase cb2 = codebaseAST(ast);
            return parseCodebase(cb2, verbosity=verbosity);
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
