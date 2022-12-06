#!/usr/bin/env awk -f
BEGIN {
    input_mode = 1
}
/\[/ {
    if (input_mode != 1) {
        print "DATA ERROR"
        exit _exit=1
    }
    columns = length($0)
    i = 0
    for (col = 2; col < columns; col += 4) {
        ++i
        crate = substr($0,col,1)
        if (crate != " ") {
            stack[i] = crate stack[i]
        }
    }
}
/^ [ [:digit:]]+ $/ {
    if ((input_mode != 1) || (length($0) != length(stack) * 4 - 1)) {
        print "DATA ERROR"
        exit _exit=1
    }
    input_mode = 2
    # for (i in stack) { print i, stack[i] }
}
/^$/ {
    if (input_mode != 2) {
        print "DATA ERROR"
        exit _exit=1
    }
    input_mode = 3
}
match($0, /^move ([[:digit:]]+) from ([[:digit:]]+) to ([[:digit:]])$/, field) {
    if (input_mode != 3) {
        print "DATA ERROR"
        exit _exit=1
    }
    for (i = 1; i <= field[1]; ++i) {
        top = length(stack[field[2]])
        crate = substr(stack[field[2]], top)
        stack[field[2]] = substr(stack[field[2]], 1, top - 1)
        stack[field[3]] = stack[field[3]] crate
    }
}
END {
    if (_exit) {
        exit _exit
    }
    for (i in stack) {
        top = length(stack[i])
        if (top < 1) {
            print "PROCESSING ERROR"
            exit _exit=1
        }
        tops = tops substr(stack[i],top)
    }
    print tops
}
