module checkFixedPoint

import display;
import vctypes;

extend Exception; // ParseError

import IO; // readFile, println, getResource
import Map; // size
import Node; // toString
import ParseTree; // parse
import Set; // sort, getFirstFrom
import String; // trim, size, intercalate

/*
    checks whether the branch ends up in a fixed point

    -1: no fixed point found (max number of attempts exhausted)
    0: it was already in a fixed point (the next application is identical to the base)
    1: it reaches a fixed point after being applied once
    2: twice
    ...: etc.
*/
int checkFixedPoint(AST base, Branch branch, int verbosity=0, int maxAttempts=4) {

    AST result = base;
    for (i <- [0..maxAttempts]) {
        AST last_result = result;

        if (1 < verbosity) {
            println("\n-- application <i+1> --");
        }

        for (patch_i <- [0..size(branch)]) {
            Patch patch = branch[patch_i];
            result = patch(result);

            if (2 < verbosity) {
                println("\n  :: patch <patch_i+1> of <size(branch)> ::\n<indent("  ", unparse(result))>");
            }
        }

        if (verbosity == 2) {
            println(result);
        }

        if (result == last_result) {
            if (verbosity == 1) {
                if (i == 0) {
                    println("\n-- base and all subsequent applications --\n<base>");
                } else {
                    println("\n-- application <i> and onward --\n<result>");
                }
            }
            return i;
        }

        if (verbosity == 1 && i == 0) {
            println("\n-- base --\n<base>");
        }
    }

    if (verbosity == 1) {
        println("\n-- application <maxAttempts> (last attempt) --\n<result>");
    }
    return -1;
}
