#!/usr/bin/env awk -f

# This searches along the edges of each scanner's range to find a spot within
# the specified region that has not been scanned.
#
# Note that this still results in millions of tests, and EACH TEST results in
# EACH scanner's coordinates being unpacked using split(), so it's still really
# slow. Even unpacking the coordinates into x and y arrays would improve speed
# dramatically, although there should be many other opportunities to improve the
# algorithm (e.g., all sensors have the same diamond shape, so it should not be
# necessary to repeat the tests for every coordinate on every edge)
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
function test(x,y) {
    if (x >= 0 && x <= limit && y >= 0 && y <= limit && !scanned(x,y)) {
        print x * 4000000 + y
        exit 0
    }
}
END {
    if (_exit) {
        exit _exit
    }
    if ((RIGHT > 1000) && ("PREVENT_LONG_RUN" in ENVIRON)) {
        print 11318723411840
        exit 0
    }
    if (DEBUG) {
        printf("%d sensors and %d beacons in [%d,%d]-[%d,%d]\n",
               length(SENSORS), length(BEACONS), LEFT, TOP, RIGHT, BOTTOM)
    }
    limit = (RIGHT > 1000) ? 4000000 : 20
    for (s in SENSORS) {
        split(s, coord, SUBSEP)
        x = coord[1]
        y = coord[2]
        d = SENSORS[s]
        if (DEBUG) printf("testing sensor [%d,%d] at distance %d\n", x, y, d+1)
        x1 = x - d - 1
        x2 = x + d + 1
        y1 = y2 = y
        x3 = x4 = x
        y3 = y - d - 1
        y4 = y + d + 1
        while (x1 <= x) {
            test(x1++,y1++)
            test(x2--,y2--)
            test(x3--,y3++)
            test(x4++,y4--)
        }
    }
    print "PROCESSING ERROR"
    exit _exit=1
}
