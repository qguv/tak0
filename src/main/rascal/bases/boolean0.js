/*
    short-circuiting prevents this from being simplified further

    suppose `test()` returns a falsy value, then it is assigned to `x` and the
    second conjunct is ignored

    otherwise, `test()` returns a truthy value, so the evaluator returns the
    second conjunct
*/
var x = test() && true;
