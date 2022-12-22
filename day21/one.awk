#!/usr/bin/env awk -f
BEGIN {
    FPAT="([a-z][a-z][a-z][a-z])|([[:digit:]]+)|([-+*/])"
}
(NF == 2) && /^[a-z][a-z][a-z][a-z]: [[:digit:]]+$/ {
    VALUE[$1] = int($2)
    next
}
(NF != 4) {
    print "DATA ERROR in", $0
    exit _exit=1
}
/^[a-z][a-z][a-z][a-z]: [a-z][a-z][a-z][a-z] [-+*/] [a-z][a-z][a-z][a-z]$/ {
    COMPUTE[$1]["left"] = $2
    COMPUTE[$1]["operation"] = $3
    COMPUTE[$1]["right"] = $4
    next
}
{
    print "DATA ERROR in", $0
    exit _exit=1
}
function find_value(monkey) {
    if (!(monkey in VALUE)) {
        switch (COMPUTE[monkey]["operation"]) {
        case "+":
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) + find_value(COMPUTE[monkey]["right"])
            break
        case "-":
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) - find_value(COMPUTE[monkey]["right"])
            break
        case "*":
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) * find_value(COMPUTE[monkey]["right"])
            break
        case "/":
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) / find_value(COMPUTE[monkey]["right"])
            break
        default:
            print "PROCESSING ERROR computing", monkey
            exit _exit=1
        }
    }
    return VALUE[monkey]
}
END {
    if (_exit) {
        exit _exit
    }
    print find_value("root")
}
