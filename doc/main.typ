#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string
#import "@preview/wordometer:0.1.5": word-count

#let todo(x) = box(fill: red, inset: 2pt, text(size: 15pt, fill: white, font: "DM Mono")[\#todo: #x])

#let title = text(font: "Linux Libertine", weight: 400, size: 20pt)[
  Structural patches in Rascal:

  #set text(14pt)
  Unifying version control
  and automated refactoring
]

#let authors = (
  (
    name: [Quint #smallcaps[Guvernator]],
    email: [quint\@guvernator.net],
    email_: [quint\@guvernator.net],
    course: [Software Language Engineering],
    institute: [Vrije Universiteit Amsterdam],
    //department: [Institute for Logic, Language and Computation],
    //institute: [Universiteit van Amsterdam],
    //country: [The Netherlands],
  ),
)
#let keywords = ("version control", "automated refactoring", "structural patches", "structural diffs", "patch theory", "rascal", "metaprogramming", "reflection", "source-to-source transformations", "pijul", "git", "linting")

#let conference = (
    name:  [Software Language Engineering],
    short: [SLE #(sym.quote.r.single)26],
    year:  [2026],
    date:  [February 10--March 30],
    venue: [Vrije Universiteit, Amsterdam, Netherlands],
)

#let doi = "https://github.com/qguv"

#show: acmart.with(
  title: title,
  authors: authors,
  copyright: "none",
  conference: conference,
  doi: doi,
  /*
  affiliations: affiliations,
  */
  // Set review to submission ID for the review process or to "none" for the final version.
  // review: [\#001],
)

#show heading.where(level: 1): it => block(inset: (top: 1em, bottom: .2em), it)
#show heading: it => block(inset: (top: .6em, bottom: .2em), it)

#show list: (it) => block(inset: (y: .4em, left: 1.2em), it)

#show terms: (it) => block[
  #for term in it.children [
    - *#term.term:* #term.description
  ]
]

//#show heading.where(level: 2): set heading(numbering: none)

#let nonum(it) = [
  #set heading(numbering: none, hanging-indent: -1em)
  #it
]

#show raw.where(block: true): (it) => block(inset: (y: 1em), it)
#show math.equation.where(block: true): (it) => block(inset: (y: 1em), it)
#show figure: (it) => block(inset: (y: 1em), it)

#let definition(it) = block(outset: (y: -.5em), inset: (y: 1em, left: 1em), stroke: (left: black), it)
#show raw.where(block: true): set text(7.7pt)
#let yes = emoji.checkmark.box;
#let no = emoji.crossmark;
#show figure: set par(justify: false)

////////////////////////////////////////////////////////////////////////////////

#acmart-keywords(keywords)
#v(.5em)
#acmart-ref(to-string(title), authors, conference, doi)

= Abstract

/*
Concise summary (typically 150–300 words). Start by identifying a specific challenge in a problem domain and explain how your proposed Domain-Specific Language (DSL) addresses it more effectively than general-purpose languages (GPLs). Briefly mention the core abstractions, the implementation strategy (e.g., code generation or interpretation), and your most significant evaluation finding—such as a specific performance gain or a reduction in lines of code.
*/

#word-count(total => [
  #if (total.words < 150 or 300 < total.words) [
    #todo[word count is still #total.words]
  ]
  A commit in a version control system and a script for automatically applying a refactoring rule across a codebase (e.g. a linter) are two instances of a _source code transformation_, a function that takes a codebase and produces a new codebase.
  Unifying these concepts would allow programmers to include automated refactoring scripts as first-class citizens in their version control systems, alongside more traditional additive commits.
  Rascal, a language workbench, offers a concise way to describe source-to-source transformations which could serve as a common language for describing both types of source code transformations.
  This paper describes how a subset of Rascal can be used to describe these transformations as _structural patches_ to the parsed abstract syntax tree of the codebase.
  This paper also explores how such patches behave in the context of common operations in a version control system and introduces several properties which characterize these patches.
  Finally, the repository associated with this project contains several test cases that demonstrate the basic principle of analyzing how structural patches behave on a codebase.
])
  
= Background

/*
- Context: Delineate the "semantic gap" in current engineering practices for your domain.

- Problem Statement: Explicitly state why existing tools or GPLs are insufficient (e.g., excessive boilerplate, lack of domain-aware verification).

- Contributions: Provide a clear list of what this paper adds to the field of software language engineering. Typical contributions include:
    - The design and design principles of the language 𝐿.
    - A formal specification of its syntax and semantics.
    - The implementation of the compiler/interpreter and supporting IDE tooling.
    - An empirical evaluation proving its efficacy (e.g., case studies or benchmarks).
*/

To understand why one would want to unify automated refactoring and version control, let us first explore these two software engineering concepts.

== Automated refactoring

_Refactoring_ involves systematically modifying all instances of a pattern in a codebase.
Examples include:

- rewriting all uses of a function (or class or other abstraction) to account for newly added functionality;

- changing variable names across a codebase when the objects they refer to no longer resemble the originally chosen name;

- _linting_ to automatically enforce consistent style rules; and

- _migrating_ to make use of newer programming language syntax or to eliminate the use of deprecated syntax.

Refactoring is sometimes done by hand, but this is tedious and error-prone.
For sizeable refactoring tasks, today's programmers typically make use of tools such as syntax-aware editors, language servers, and (increasingly) LLM-based AI assistants.
However, while some degree of automation has become an integral part of most refactoring tasks, tools still lack in the _verifiability_, _repeatability_, and _correctness_ of the modifications that they introduce to the codebase.

By _verifiability_, I mean the ability for other tools (or code reviewers) to compare a description of what the tool _claims_ to do with the actual _concrete changes_ it effects on the codebase.
_Semi-automated_ tools, such as those provided by text editors to save programmers time while refactoring, are often triggered live by user interaction and effect immediate changes onto the codebase; the total lack of a descriptive record of the batch processes such tools perform on the concrete syntax of the codebase makes verification of their behavior difficult.
Similarly, some tools such as `2to3` and `eslint` are (partially) heuristic-based; in the documentation for these tools, programmers are instructed to manually verify and approve each and every _concrete change_ that these tools suggest. While this may be reasonable for small changes, this quickly becomes unwieldy for large codebases or for refactoring tasks of arbitrary complexity.

By _repeatability_, I am primarily concerned with a particular type of determinism: the ability for developers on the same project to get the same results when using the same tool for the same refactoring task.

By _correctness_, I mean that the tool produces neither false negatives (missed patterns that are therefore not refactored) nor false positives (patterns that are changed unnecessarily).

The growing popularity of one kind of refactoring tool, the LLM-based AI tool, is especially troubling, because the non-determinism and general opaque nature of these tools causes them to lack every one of these properties.

== Version control

A _version control system_ (VCS) is a suite of tools to help programmers keep track of changes they make to source code repositories over time. Some examples include `git`, `darcs`, and `pijul`.
A good VCS:

- allows developers to collaborate across time and space;
- allows different variants of the codebase to be maintained simultaneously;
- shows how the codebase has changed over time;
- allows mistakes discovered later to be reverted granularly; and
- supports other devops tools such as a build/test pipeline or staged releases.

Changes to a codebase are represented by _commit objects_.
The norm in version control systems today is for these commits to represented unix patches:
a list of all removed and added lines,
along with some context lines to make them more robust to trivial in-file movement operations.
As no syntactic information is expressed in these commit objects, the ability to revert, reorder, or merge commits (without manual intervention) is limited to cases without _merge conflicts_, that is, without any overlapping of the sections of code targeted by the commits involved.

== Unification

If, rather than being textual diffs, commits instead represented directives to an automated refactoring system to make a particular kind of change across every instance across the codebase of a specified pattern, it would be possible to unify version control and automated refactoring, creating commits that are more robust to reordering, reverting, and merging, and enabling anyone using version control to leverage the power of automated refactoring tools.

= Domain analysis

/*
This section justifies your language design through a systematic study of the problem area.
*/

The domain consists of text in a variety of formal languages, running the gambit from general-purpose programming languages to domain-specific languages to potentially even human languages (for things like automated style and grammar correction or rewriting of jargon terms).

Programmers iteratively make changes to these codebases by running automated refactoring tools or manually making changes, adding them to a staging area, and committing the result to a _commit object_ in their version control system of choice.

When history diverges or needs to be re-ordered, some programmer (often a more senior one) is responsible for determining how to resolve any merge conflicts that arise. This often happens under a time crunch, as a release is being prepared.

== Stakeholders and use cases

// Identify who will use the language and for what tasks (e.g., documentation vs. code generation).

Users of both VCS and automated refactoring are experienced programmers.
While any modification to their typical workflow is likely to result in initial resistance, these users are undoubtedly technical enough to learn to write abstract code to target and modify code in their codebase.
Programmers who are responsible for merging changes are more likely to care about avoiding merge conflicts than programmers whose primarily task is to deliver features.
Because of this, any improvements to version control or automated refactoring tooling must be intuitive enough to use that programmers _without_ merge responsibilities still feel compelled to adopt the new paradigm necessary to use them.

== Requirements

// List the technical requirements for the language, such as incrementality, persistence, or correctness.

Rather than using line diffs as the main change objects in a version control system to describe _what_ has changed, I propose to use a format that describes _how to generate_ a particular change on the codebase, in the style of an automated refactoring tool.
These _structural diffs_ are aware of the syntax of the language that the code is written in, and should contain sections to:

- select all instances of a particular pattern;
- extract data from the existing structure of the pattern or other nearby sections of code/structure;
- synthesize new syntax elements from the extracted data;

in addition to a natural language description of the change and pointers specifying its location in the change graph.
It should be possible for programmers to read and write these patches without special assistance (though see @sec:future-work for a discussion of how this could partially be automated).


= Operations and properties of a structural patch-based VCS

Any VCS must support the basic version control operations (viz. committing, reverting, branching, merging, and rebasing). As committing, reverting, and branching are relatively trivial problems, we will focus here on merging and briefly mention rebasing. We also introduce some notation for discussing sequential application of patches to a codebase.

== Committing <sec:committing>

As previously mentioned, this paper focuses on hand-written structural patches, while automatic extraction of such patches is left for future work, see @sec:future-work below. Not much remains to be done by the VCS.

However, as applying patches to a codebase is a fundamental operation, we must first introduce a convention for writing about the various states that can be reached by applying structural patches to a codebase.

We will use $@$ to refer to some initial state of the codebase. Structural patches are given with lowercase letters and are applied left-to-right (akin to Polish notation). For example, $@ a b$ is the state reached from the codebase $@$ by first applying patch $a$, and then $b$. Depending on the patches involved, this may be a different state than $@ b a$. When applying a sequence of patches, we use capital letters, so $@ A B$ represents first applying all the patches from the branch or sequence $A$, and then applying all the patches from $B$. For example, the states $@ A$ and $@ B$ can be rebased in two ways: $@ A B$ or $@ B A$. Note that it is possible to have singleton or even empty sequences.

We can now move on to a much more interesting operation: that of merging different branches together.

== Merging

Merging is a particularly interesting operation, as a structure-aware VCS can use structural information to make merging easier by detecting trivial merges more often than a line-based VCS, as well as less error-prone by working with a patch script that applies to the whole codebase rather than a fixed list of change locations which can become outdated as additional contributors add more instances of a pattern unbeknownst to a commit author.

#set enum(indent: 1em)
#show enum: (it) => box(inset: (y: .6em), it)

Line-based VCSs can encounter merge conflicts for many reasons, e.g.:
  1. because files are renamed;
  2. because of silly syntactic issues such as presence or absence of trailing commas or whitespace changes;
  3. because instances were missed, or were added later without the author's knowledge (results not in a failed/manual merge but a silently wrong merge, which is much worse);
  4. because variables are renamed;
  5. because two patches clobber each other's context;
  6. because the changes in the two branches are fundamentally incompatible.
Many version control systems can handle case 1 by keeping track of file-level renames, and some have special flags or break out to external tools to handle case 2.
Structural patches have the potential to eliminate cases 2, 3, and 4.
Case 5 is a fundamentally difficult problem for any version control system, as we will see below.
This leaves case 6, the only case here where failure is intentional. Any correct version control system _must_ detect incompatible patches and pass the problem to the user to solve manually.

=== Patch properties <sec:patch-properties>

To decide how to automatically merge two branches safely, a structural VCS would need to know some properties of the patches involved.

#nonum[
==== Triviality
]

One of the easiest notions to capture is the notion that a commit does not apply in a particular situation. Using the notation described in @sec:committing above, we can rigorously capture this idea as follows:

#definition[
  A sequence $A$ is _trivial_ on a codebase $@$ iff #box[$@=@ A$].
]

If $C$ is nontrivial on $@$, but after applying $B$ to create $@ B$, $C$ is now trivial on this new codebase, we can say that $B$ trivializes $C$ on $@$. Formally:

#definition[
  Suppose the sequences $B$ and $C$ are nontrivial on $@$. $B$ _trivializes_ $C$ on $@$ iff $C$ is trivial on $@ B$ (that is, iff $@ B = @ B C$).
]

We can also define its opposite:

#definition[
  Suppose the sequences $D$ and $E$ are nontrivial and trivial, respectively, on $@$. $D$ _untrivializes_ $E$ iff $E$ is nontrivial on $@ D$.
]

Finally, one relatively trivial observation:

#definition[
  Lemma:
    the empty sequence is trivial on any codebase.
  Proof:
    take an arbitrary codebase $@$ and let $F$ represent the empty sequence.
    As $F$ is empty, $@ F = @$.
    By the definition of triviality, $F$ is therefore trivial on $@$.
    Without loss of generality, $F$ is trivial on any codebase.
]

This notion of triviality is a sort of identity, where the codebase is left unaffected by one application of a sequence.
#nonum[
==== Fixed points
]

We can relax this notion of triviality to capture sequences that require more than one application to stabilize. First, a bit of notation: for any $n in NN$, let $@ G^n$ refer to applying $G$ to $@$ repeatedly, $n$ times:
$
  @ underbrace(G G ... G, n "times")
$
We can now define fixed points in much the same spirit as the triviality definition above:
#definition[
  A sequence $H$ has a _fixed point_ on a codebase $@$ iff there exists some $n in NN$ such that $@H^n=@H^(n+1)$.
]

Some kinds of structural patches, like _lints_ (automatic corrections that linters make to the style of code in the codebase), are meant to be applied over and over again until they stop having an effect---that is, until they become trivial. Unlike other patches, it is generally a _good_ thing if a lint is trivial, as this indicates that there are no problematic style issues that need to be fixed.

But lints are not only fixed points on a particular codebase; they are designed to be fixed points on _any_ code base. We will say that a lint is one example of a _general fixed point_.

#definition[
  A sequence $I$ is _fixed point idempotent_ iff for _any_ codebase $@$, there exists some $n in NN$ such that $@ I^n = @ I^(n+1)$.
]

Proving that a structural patch is fixed point idempotent can be done by induction, by showing that the code complexity decreases at each step. This is left for future work, see @sec:future-work below.

It is important to identify fixed-point idempotent branches and patches when merging, because they are very flexible and can be generally reordered or repeated without issue. If, during the merge process, the merge algorithm discovers that a lint trivializes another commit, then we can apply the lint later (or not at all, if we get the same lint elsewhere in the commit graph).

#nonum[
==== Commutativity
]

Another very important property is whether the order that branches are applied matters.
Using the notation described in @sec:committing above, we can rigorously capture the idea of order sensitivity between commits or branches.

#definition[
  For a given codebase $@$, a set of sequences $SS$ _commutes_ iff every permutation of $SS$, when applied sequentially to $@$, results in the same value. For example, $SS:={J,K}$ commutes iff $@ J K = @ K J$, and $SS:={L,M,N}$ commutes iff
  $@ L M N = @ L N M = @ M L N = ...$
]

If two branches commute, they are likely to be safe to merge, because the context of each was not trivialized by the other.

#nonum[
==== Behavior isomorphism
]

#definition[
  A sequence $A$ is behavior-isomorphic on $@$ if the behavior of the software built from the codebase $@ A$ is identical to the behavior of the software built from $@$.
]

For example, lints are behavior-isomorphic by design, as are renames of bound variables, but additive commits (commits that introduce new pieces of code) are not.

=== Properties of typical structural patches

While version control and automated refactoring have striking similarities, their clear differences make up the majority of the challenge of unification.
Now that some terminology has been introduced, we can take a brief survey of the types of patch that will need to be represented in the combination VCS/refactoring tool, see the table in @sec:properties-survey[appendix] below.

In particular, note the rows describing whether patches of each type are allowed to refer to or introduce local variables; this is an important factor for determining the order in which branches can be applied. 

Note also that "bound variable rename" offers lots of potential for safely coaxing together two branches which differ only in _alpha-equivalence_; that is, they clash only in the names they have for local variables. By keeping track of renames, changing the order that they are performed, "prefixing" and "suffixing" a sequence with protective local variable renames to prevent clashing. (Unfortunately, this is not yet possible, see @sec:limitations for discussion.)

= Implementation <sec:implementation>

/*
Discuss the technical development of your DSL, often us- ing a language workbench. If not, explain why and your motivation behind this design decision.

- Workbench Infrastructure: Identify the tools used (e.g., Spoofax, Xtext, MontiCore, or MPS).

- System Architecture: Describe the split of the front-end (parsing and semantic analysis) and back-end (code genera- tion or interpretation).

- Tooling Support. : Mention generated IDE features like syntax highlighting, auto-completion, and real-time error reporting.
*/

I implemented a framework for manipulating source by applying patches and branches written in the Rascal language to a few minimal codebases (just a couple lines each) written in Javascript, one of the languages for which Rascal has out-of-the-box support (albeit almost a decade out of date). My framework can additionally checking for triviality, check whether merges commute, and check for and demonstrate fixed point convergence.
The tests try to demonstrate the variety of structural patches and refactoring tasks that can be represented as Rascal source-to-source rewrites.

The Rascal language workbench offers syntax to traverse ASTs and can make changes to those elements on the fly, making it an ideal choice for representing semantic patches.
@figure:remove_disjunction below shows a structural patch to eliminate disjunctive expressions involving literals:
#figure(caption: [a simple structural patch to eliminate

redundant disjunction expressions])[
```java
Source remove_disjunction(Source unit) = innermost visit(unit)
{
    case (Expression) `false || <Expression a>` => a
    case (Expression) `true || <Expression _>` =>
         (Expression) `true`
};
```
] <figure:remove_disjunction>
Rascal's `visit` directive explores a given AST according to its strategy (`innermost` in the case of @figure:remove_disjunction) and rewrites instances it encounters which match any of the given `case` patterns to the provided replacements. The replacements can refer to variables bound in the patterns, and Rascal's support for writing patterns using the same concrete syntax as the target language makes it an ergonomic language for writing source-to-source transformations of this kind.

= Evaluation

/*
The evaluation must demonstrate that your DSL delivers on its core promises.

- Case Studies: Re-implement a known complex system to demonstrate how domain abstractions simplify the solution. Report quantitative improvements, such as a reduction factor in lines of code.

- Performance Benchmarks: For performance-critical DSLs, provide execution time or memory usage data compared with hand-coded GPL baselines. User Studies: If targeting "lay pro- grammers" or domain experts, report on usability metrics such as task completion time and error rates.
*/

The repository associated with this project includes a suite of test cases to help demonstrate the various properties discussed in @sec:patch-properties as a first step toward a merge algorithm that takes advantage of the unique structure-awareness of structural patches.

Each test case is a Javascript source file, several structural patches written in Rascal to represent branches, and a directive to analyze some structural patch property.
The test cases demonstrate:

- a merge where both branches are trivial and therefore (trivially) commute;
- a non-trivial merge that commutes;
- two non-trivial merges that don't commute;
- a three-way merge that doesn't commute;
- a trivial patch that is (trivially) idempotent;
- an additive patch (i.e. that introduces _new_ source code) which is fixed-point idempotent (this is noteworthy and atypical);
- an additive patch which is not fixed-point idempotent (this is the usual case); and
- a longer fixed point demonstration where repeated applications unblock subsequent rule applications.

== Limitations <sec:limitations>

One of the most promising operations that structural patches enable, at least in theory, is renaming local variables. Creative application of generated patches can be used to massage branches into merging when this would otherwise not be possible (see also: discussion in @sec:patch-properties above).

Unfortunately, it does not appear to be possible to rename local variables using the same simple language as the patch format described in @sec:implementation. The AST of the language used for testing (Javascript) does not keep track of variable scope, and an attempt to recover this information was fruitless yet extremely time-consuming.
Tracking and managing local variable renaming is a critical component of a structural VCS, and Rascal's lack of out-of-the-box support for this is a big drawback for using Rascal source to write structural patches.

= Conclusion

// Summarize the findings and discuss the implications of your work.

In this paper, I have outlined the first exploratory steps toward building a VCS based on structural patches.
I have discussed some key properties of branches that influence a VCS's ability to automatically merge them safely and without conflicts.
In the associated repository, I demonstrate some of these principles by means of observable test cases.

Structural patches offer a promising alternative to VCSs based on line diffs, and by leveraging the properties described in this paper, it may prove to be a powerful tool, facilitating automated refactoring, linting, and provable edits to every user of version control.

// In addition to the benefits of avoiding merge conflicts by specifying commits as structural modifications, there is yet another advantage to this paradigm: putting verifiable, deterministic, correct automated refactoring tools in the hands of every user of version control.

= Future work <sec:future-work>

// Identify future research directions, such as scaling the DSL, language evolution, or integrating AI-assisted design.

== Abstracting modifications into structural patches

In many cases, hand-writing a structural description of a simple one-line change may be less ergonomic than simply bringing the codebase to the desired end state (i.e. making the desired change).
To support such cases, it may be possible to _automatically abstract_ an applied change into a structural patch.
Of course, there will be many such suitable abstractions for any one applied change, so a programmer would still need to _disambiguate_ the result.

Furthermore, the simplicity of directly bringing (a part of) the codebase to a desired state could even be used to make writing refactoring patches easier. The programmer could manually apply the intended change to a _portion_ of the codebase (say, one file) and ask the version control system to generate a script _generalizing_ the change to the rest of the codebase. Like in the case of pure abstraction, this process of generalization also requires the user to disambiguate, but in addition to disambiguating among identical results, the programmer must now also disambiguate between different ways of generalizing, which produce different results. It is therefore imperative that this process be interactive, giving the user the chance to _preview_ the results on the rest of the codebase.
The user experience of the preview operation must be carefully designed because, like reviewing an automatic merge in a standard, line diff-based version control system, false negatives are exceedingly difficult to catch.

// Programmers could write code as usual, and then when they are ready to create a commit, the version control software could capture different ways that the actual concrete changes they made to the codebase could be captured and abstracted as rewriting rules, from which the programmer would then select (_disambiguate_) one particular rule that they think is sufficiently general to allow for complex commit reordering, reverting, and merging operations in the future. A crucial component of this generalization would be to inspect a _preview_ of how the changes would generalize to apply elsewhere in the codebase than the programmer explicitly specified, allowing the programmer to make an intelligent decision about which abstraction to choose.

== Proving fixed point idempotence

Proving that a structural patch is fixed point idempotent can be done by induction, by showing that the code complexity decreases at each step, similarly to how termination is proved in recursive calls in Lean 4.

// #bibliography("refs.bib", title: "References", style: "association-for-computing-machinery")

//#colbreak(weak: true)
#set page(columns: 1)
#counter(heading).update(0) 
#set heading(numbering: "A.a")
= Appendix: properties of several types of structural patches <sec:properties-survey>
#figure(
  //caption: [My caption],
  table(
    columns: 7,
    [], [lint], [additive commit], [bound variable rename], [inlining a function], [abstracting a function], [security patch],
    [behavior-isomorphic], yes, no, yes, yes, yes, no,
    [fixed-point idempotence], yes, no, yes, yes, yes, yes,
    [...in one shot?], no, [---], yes, yes, no, yes,
    [can refer to bound var by name], no, yes, yes, yes, no, no,
    [can introduce bound var], no, yes, yes, no, yes, no,
    [invertible], no, no, yes, no, yes, no,
  )
)
