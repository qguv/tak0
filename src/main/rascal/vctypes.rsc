module vctypes

import js2;

alias AST = Source;
alias Patch = Source(Source);
alias Branch = list[Patch];
alias Merge = tuple[Source base, list[Branch] branches];
