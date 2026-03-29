module Main

import codebase;
import commute;
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

void demo(int verbosity=0) {

    int test_i = 0;
    list[Testcase] allTests = getTestcases();
    for (<case_name, base_codebase, prop> <- allTests) {
        if (0 < verbosity) {
            println("");
        }
        println("\n== test <test_i+1> of <size(allTests)>: <case_name> ==");
        test_i += 1;

        try {
            AST base = parseCodebase(base_codebase, verbosity=verbosity);
            switch (prop) {

                case propCommutes(branches): {
                    map[AST, list[str]] results = checkCommute(<base, branches>, verbosity=verbosity);

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

                    if (0 < verbosity) {
                        println("\n-- results --");
                    }

                    str trivial = (
                        base in results ? (
                            size(results) == 1 ? "always"
                            : "sometimes"
                        )
                        : "never"
                    );
                    print(ansi_bold("  trivial?"));
                    println("      <trivial>");
                    print(ansi_bold("  commutes?"));
                    println("     <
                        trivial == "always" ? "yes     <ansi_italic("(trivially)")>"
                        : size(results) == 1 ? "yes"
                        : "no      (<ansi_italic(intercalate(" != ", sort([intercalate("/", sort(results[r])) | r <- results])))>)"
                    >");
                }

                case propFixedPoint(branch): {
                    int fixedPointAfter = checkFixedPoint(base, branch, verbosity=verbosity);
                    if (0 < verbosity) {
                        println("\n-- result --");
                    }
                    switch (fixedPointAfter) {
                        case -1: {
                            print(ansi_bold("  fixed point?"));
                            print("  no      ");
                            println(ansi_italic("(maximum attempts exceeded)"));
                        }
                        case 0: {
                            print(ansi_bold("  fixed point?"));
                            print("  yes     ");
                            println(ansi_italic("(base was already a fixed point)"));
                        }
                        default: {
                            print(ansi_bold("  fixed point?"));
                            print("  yes     ");
                            println(ansi_italic("(converges after <fixedPointAfter> branch applications)"));
                        }
                    }
                }
            }

        } catch ParseError(loc l): {
            println("javascript parse error in <l>\n  line <l.begin.line>, column <l.begin.column>");
        }
    }
}

/*
    checks whether the branch ends up in a fixed point

    -1: no fixed point found (max number of attempts exhausted)
    0: it was already in a fixed point (the next application is identical to the base)
    1: it reaches a fixed point after being applied once
    2: twice
    ...: etc.
*/
int checkFixedPoint(AST base, Branch branch, int verbosity=0) {
    maxAttempts = 3;

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
        println("\n-- repetition <maxAttempts> (last attempt) --\n<result>");
    }
    return -1;
}

/*
    verbosity: pass multiple `-v` flags on the command line to increase verbosity. you can also use a repeated `-vv...`. for example, `-v -vv` and `-vvv` both set verbosity to 3

    levels:

    0. just show the properties of each merge
    1. show each *unique* output generated by one or more permutations, labelled with the permutation(s) that generated it, followed by the results
    2. show each permutation and its output in order, followed by the results
    3. as above, but also show the intermediate state after applying each branch in a permutation
    4. as above, but also show the intermediate states after applying each patch in a branch
*/
int get_verbosity(list[str] args) {
    return (0 | it + size(arg) - 1 | arg <- args, startsWith(arg, "-v"));
}

void main(list[str] args) {
    int verbosity = get_verbosity(args);
    demo(verbosity=verbosity);
}
