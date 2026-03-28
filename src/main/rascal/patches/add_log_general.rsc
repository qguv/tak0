module patches::add_log_general
import js2;

Source add_log_general(Source unit) = bottom-up-break visit(unit) {
    case
        (Statement) `function hello() { <Statement* a> }` =>
        (Statement) `function hello() { <Statement* a> console.log("how are you?"); }`
};
