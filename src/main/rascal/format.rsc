module format

import List; // size
import String; // intercalate, split

str plural(str s, list[value] xs) {
    return size(xs) == 1 ? s : "<s>s";
}

str indent(str prefix, str s) {
    list[str] lines = split("\n", s);
    lines = [prefix + line | line <- lines];
    return intercalate("", lines);
}

public str letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
