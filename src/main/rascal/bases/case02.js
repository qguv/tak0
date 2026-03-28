function max(x, y) {
    var y_is_bigger = x < y;
    if (y_is_bigger) {
        return y;
    } else {
        return x;
    }
}
