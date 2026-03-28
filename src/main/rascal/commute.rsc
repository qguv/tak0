module commute

import codebase;
import display;
import testcases;
import vctypes;

extend Exception; // ParseError

import IO; // readFile, println, getResource
import Map; // size
import Node; // toString
import ParseTree; // parse
import Set; // sort, getFirstFrom
import String; // trim, size, intercalate

map[AST, list[str]] checkCommute(Merge merge, int verbosity = 0) {
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
