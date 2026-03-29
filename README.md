# tak0

_early experiments toward unifying version control and automated refactoring_

## running

- Install the JDK on your machine (openjdk 11 or higher).
- Run `./run.sh` with a unix-based shell to execute the test cases with the usual verbosity, which will show just the salient/unique/relevant outputs from each case.
- To get a better idea of what's happening under the hood, consider enabling verbose output:
    - `./run.sh -vvv` to show each patch, of each branch, of each permutation being evaluated step by step **(try this at least once!)**
    - `./run.sh -vv` to show each branch of each permutation being evaluated step by step
    - `./run.sh -q` to skip the intermediate results and just print the values we found for the properties

## creating your own experiments

- Create a base Javascript file `src/main/rascal/bases/CHANGE_ME.js`, or reuse an existing one. This will be your codebase.
- Create one or more patches in Rascal at `src/main/rascal/patches/CHANGE_ME.rsc` or reuse an existing one. These are the structural patches you can use to build up and test branches.
- Add a case in `src/main/rascal/testcases.rsc`:

```rascal
<
    "some additive patches are idempotent", // <---------- name of your test
    codebasePath(getResource("bases/function.js")), // <-- filename of base
    propFixedPoint([add_log_specific])  // <-------------- branch or branches
    /* ^
       |__ type of test to run (any VCProperty, so currently either `propFixedPoint` or `propCommutes`. Or make your own!) */
>,
```
