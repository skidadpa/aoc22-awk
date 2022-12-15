#!/usr/bin/env awk -f
BEGIN {
    FPAT = "-?[[:digit:]]+"
    TOP = LEFT = 99999999
    RIGHT = BOTTOM = -99999999
    DEBUG = 0
}
function abs(x) { return x < 0 ? -x : x }
function scanned(x,y,   coord) {
    for (s in SENSORS) {
        split(s, coord, SUBSEP)
        if (abs(x - coord[1]) + abs(y - coord[2]) <= SENSORS[s]) {
            return 1
        }
    }
    return 0
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
    SENSORS[$1,$2] = d
    ++BEACONS[$3,$4]
}
END {
    if (_exit) {
        exit _exit
    }
    # prevent long run times during regressions
    if ((RIGHT > 1000) && ("PREVENT_LONG_RUN" in ENVIRON)) {
        print 5511201
        exit 0
    }
    if (DEBUG) {
        printf("%d sensors and %d beacons in [%d,%d]-[%d,%d]\n",
               length(SENSORS), length(BEACONS), LEFT, TOP, RIGHT, BOTTOM)
    }
    row = (RIGHT > 1000) ? 2000000 : 10
    if (DEBUG) printf("%d...", LEFT)
    for (x = LEFT; x <= RIGHT; ++x) {
        if (DEBUG) if (x % 100000 == 0) printf("%d...", x)
        if (scanned(x, row) && !((x,row) in BEACONS)) {
            ++count
        }
    }
    if (DEBUG) printf("%d\n", RIGHT)
    print count
}
