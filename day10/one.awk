#!/usr/bin/env awk -f
BEGIN {
    X = 1
}
function advance_time(  signal_strength) {
    ++cycle
    if (((cycle - 20) % 40 == 0)) {
        signal_strength = X * cycle
        sum += signal_strength
    }
}
/^noop$/ {
    advance_time()
    next
}
/^addx -?[[:digit:]]+$/ {
    advance_time()
    advance_time()
    X += int($2)
    next
}
{
    print "DATA ERROR"
    exit _exit=1
}
END {
    if (_exit) {
        exit _exit
    }
    print sum
}
