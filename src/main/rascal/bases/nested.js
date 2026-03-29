function nested() {
    return (true && true || false) && (false && (true && true || false)) || (true && true) && (true || false);
}
