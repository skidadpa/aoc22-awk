#!/usr/bin/env awk -f
BEGIN {
    VALUE["="] = -2
    VALUE["-"] = -1
    VALUE["0"] = 0
    VALUE["1"] = 1
    VALUE["2"] = 2
    DIGIT[0] = "0"
    DIGIT[1] = "1"
    DIGIT[2] = "2"
    DIGIT[3] = "="
    DIGIT[4] = "-"
    CARRY[0] = 0
    CARRY[1] = 0
    CARRY[2] = 0
    CARRY[3] = 1
    CARRY[4] = 1
    DEBUG = 0
}
function convert_from_snafu(sn,   len, SNAFU, mult, n, i) {
    len = split(sn, SNAFU, "")
    mult = 1
    n = 0
    for (i = len; i >= 1; --i) {
        n += mult * VALUE[SNAFU[i]]
        mult *= 5
    }
    return n
}
function convert_to_snafu(n,   sn, d) {
    sn = ""
    while (n > 0) {
        d = (n + c) % 5
        sn = DIGIT[d] sn
        n = int(n / 5) + CARRY[d]
    }
    return sn
}
($0 !~ /^[12][-=012]*$/) {
    print "DATA ERROR"
    exit _exit=1
}
{
    sum += convert_from_snafu($0)
    if (DEBUG > 2) {
        print $0, "==", convert_to_snafu(convert_from_snafu($0))
    }
    if (DEBUG > 1) {
        print $0, "=>", convert_from_snafu($0)
    }
}
END {
    if (_exit) {
        exit _exit
    }

    if (DEBUG > 2) {
        split("1 2 3 4 5 6 7 8 9 10 15 20 2022 12345 314159265", VALS)
        print "decimal => SNAFU"
        for (v in VALS) {
            print VALS[v], convert_to_snafu(VALS[v])
        }
    }
    if (DEBUG) {
        print "sum is", sum
    }
    if (DEBUG > 2) {
        print convert_from_snafu(convert_to_snafu(sum))
    }

    print convert_to_snafu(sum)
}
