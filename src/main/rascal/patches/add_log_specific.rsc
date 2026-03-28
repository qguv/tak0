module patches::add_log_specific
import js2;

Source add_log_specific(Source unit) = innermost visit(unit) {
    case
        (Statement) `function hello() { <Statement a> }` =>
        (Statement) `function hello() { <Statement a> console.log("how are you?"); }`
};
