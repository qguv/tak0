module display


import String; // split
import List; // size

public str letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

str indent(str prefix, str s) {
    list[str] lines = split("\n", s);
    return ("" | it + prefix + line | line <- lines);
}

str plural(str s, list[value] xs) {
    return size(xs) == 1 ? s : "<s>s";
}
