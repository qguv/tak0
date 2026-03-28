function simple() {
    var t = !(0 < 1) ? true : false;

    if (!t) {
        console.log("was the 'then' branch");
    } else {
        console.log("was the 'else' branch");
    }

    if (!t) {
        console.log("no 'else' branch, so this can't be changed");
    }
}
