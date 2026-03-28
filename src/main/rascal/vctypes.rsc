module vctypes

import deeper::js2;

alias AST = Source;
alias Patch = AST(AST);
alias Branch = list[Patch];
alias Merge = tuple[AST base, list[Branch] branches];
