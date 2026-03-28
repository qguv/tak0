module display

import String; // split

str indent(str prefix, str s) {
    list[str] lines = split("\n", s);
    return ("" | it + prefix + line | line <- lines);
}
