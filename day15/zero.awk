#!/usr/bin/env awk -f

# This works for the sample, although the input range is too large to maintain
# a map of all points...

BEGIN {
    FPAT = "-?[[:digit:]]+"
    TOP = LEFT = 99999999
    RIGHT = BOTTOM = -99999999
    DEBUG = 1
}
function abs(x) { return x < 0 ? -x : x }
function draw_map(   x, y) {
    printf("[%d,%d]-[%d,%d]:\n", LEFT, TOP, RIGHT, BOTTOM)
    for (y = TOP; y <= BOTTOM; ++y) {
        printf("%08d: ", y)
        for (x = LEFT; x <= RIGHT; ++x) {
            printf("%c", (x,y) in MAP ? MAP[x,y] : ".")
        }
        printf("\n")
    }
}
(NF != 4 || $0 !~ /^Sensor at x=[[:digit:]]+, y=[[:digit:]]+: closest beacon is at x=-?[[:digit:]]+, y=-?[[:digit:]]+$/) {
    print "DATA ERROR"
    exit _exit=1
}
{
    d = abs($1 - $3) + abs($2 - $4)
    if ($1 + d > RIGHT) RIGHT = $1 + d
    if ($1 - d < LEFT) LEFT = $1 - d
    if ($2 + d > BOTTOM) BOTTOM = $2 + d
    if ($2 - d < TOP) TOP = $2 - d
    if (DEBUG) printf("[%d,%d] detected [%d,%d] at distance %d\n",$1,$2,$3,$4,d)
    if ((($1,$2) in MAP) && (MAP[$1,$2] != "#")) {
        print "PROCESSING ERROR: sensor location previously scanned as", MAP[$1,$2]
        exit _exit=1
    }
    if ((($3,$4) in MAP) && (MAP[$3,$4] != "B")) {
        print "WARNING: beacon location previously scanned as", MAP[$3,$4]
        exit _exit=1
    }
    MAP[$1,$2] = "S"
    MAP[$3,$4] = "B"
    for (x = $1 - d; x <= $1 + d; ++x) for (y = $2 - d; y <= $2 + d; ++y) {
        if (((abs(x - $1) + abs(y - $2)) <= d) && !((x,y) in MAP)) {
            MAP[x,y] = "#"
        }
    }
    if (DEBUG) draw_map()
}
END {
    if (_exit) {
        exit _exit
    }
    row = (RIGHT > 1000) ? 2000000 : 10
    for (x = LEFT; x <= RIGHT; ++x) {
        if (((x,row) in MAP) && (MAP[x,row] != "B")) {
            ++count
        }
    }
    print count
}
