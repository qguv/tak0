module display

import String; // split
import List; // size

public str letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

str ansi_bold(str s) = "\u001b[1m<s>\u001b[22m";

str ansi_italic(str s) = "\u001b[3m<s>\u001b[23m";

str indent(str prefix, str s) {
    list[str] lines = split("\n", s);
    return ("" | it + prefix + line | line <- lines);
}

str plural(str s, list[value] xs) {
    return size(xs) == 1 ? s : "<s>s";
}
