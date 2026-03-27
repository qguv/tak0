# feedback for rascal

from a brand new user

## negative

- difficult to find information about iterating over maps
- what's the difference between `rel` and `map`? probably documentation but not immediately clear from the docs of `map` and from the cheatsheet
- cheatsheet would benefit from links to full documentation
- more info on generic syntax in cheatsheet would be nice
- how to combine `when` clauses
- even after reading documentation for `parse` and in general on ASTs, it's difficult to figure out what the traversal strategies mean. for "innermost" the "continue until match" is weird

### pattern matching

- `Expression!function`, `!div` from cheatsheet not explained
- comment `// reject` by `!div` not explained, also not immediately obvious what's being done here... why would divided expressions be unacceptable dividends/divisors for a division operation?

### imports

- no scoped imports? `from x import y`
- upwards imports? from a source file deep in a folder: `import root::whatever`?

## positive

- `permutations(list[...])` saved me a bunch of time
