module deeper::codebase

import vctypes;

import String; // trim
import ParseTree; // parse
import IO; // readFile, println

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
