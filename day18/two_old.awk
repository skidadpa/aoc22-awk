#!/usr/bin/env awk -f
BEGIN {
    FS = ","
    XMIN = YMIN = ZMIN = 999
    XMAX = YMAX = ZMAX = -999
    DEBUG = 1
}
(NF != 3) || ($0 !~ /^[[:digit:]]+,[[:digit:]]+,[[:digit:]]+$/) {
    print "DATA ERROR"
    exit _exit=1
}
{
    CUBES[$1,$2,$3] = 1
    CHECKED[$1,$2,$3] = 1
    if (XMIN > $1) XMIN = $1
    if (XMAX < $1) XMAX = $1
    if (YMIN > $2) YMIN = $2
    if (YMAX < $2) YMAX = $2
    if (ZMIN > $3) ZMIN = $3
    if (ZMAX < $3) ZMAX = $3
}
function look_for_exterior(x, y, z,   test) {
    if ((x < XMIN) || (x > XMAX) || (y < YMIN) || (y > YMAX) || (z < ZMIN) || (z > ZMAX)) {
        EXTERIOR[x,y,z] = 1
        CHECKED[x,y,z] = 1
        return 1
    }
    if ((x,y,z) in EXTERIOR) return 1
    if ((x,y,z) in CHECKED) return 0
    CHECKED[x,y,z] = 1
    test = (look_for_exterior(x-1,y,z) || look_for_exterior(x+1,y,z) ||
            look_for_exterior(x,y-1,z) || look_for_exterior(x,y+1,z) ||
            look_for_exterior(x,y,z-1) || look_for_exterior(x,y,z+1))
    if (test) EXTERIOR[x,y,z] = 1

    return test
}
function find_adjacent_exterior(x, y, z) {
    look_for_exterior(x-1,y,z)
    look_for_exterior(x+1,y,z)
    look_for_exterior(x,y-1,z)
    look_for_exterior(x,y+1,z)
    look_for_exterior(x,y,z-1)
    look_for_exterior(x,y,z+1)
}
function exposed_sides(x, y, z,   count) {
    count = 0
    if ((x-1,y,z) in EXTERIOR) ++count
    if ((x+1,y,z) in EXTERIOR) ++count
    if ((x,y-1,z) in EXTERIOR) ++count
    if ((x,y+1,z) in EXTERIOR) ++count
    if ((x,y,z-1) in EXTERIOR) ++count
    if ((x,y,z+1) in EXTERIOR) ++count

    if (!((x-1,y,z) in CHECKED)) print "unchecked", x, y, z
    if (!((x+1,y,z) in CHECKED)) print "unchecked", x, y, z
    if (!((x,y-1,z) in CHECKED)) print "unchecked", x, y, z
    if (!((x,y+1,z) in CHECKED)) print "unchecked", x, y, z
    if (!((x,y,z-1) in CHECKED)) print "unchecked", x, y, z
    if (!((x,y,z+1) in CHECKED)) print "unchecked", x, y, z
    return count
}
function verify_interior(x, y, z) {
    if ((x,y,z) in EXTERIOR) {
        print "PROCESSING ERROR, non-internal", x, y, z
        exit _exit=1
    }
    if (!((x,y,z) in CHECKED)) {
        print "PROCESSING ERROR, unchecked", x, y, z
        exit _exit=1
    }
    if (!((x,y,z) in CUBES)) {
        verify_interior(x-1,y,z)
        verify_interior(x+1,y,z)
        verify_interior(x,y-1,z)
        verify_interior(x,y+1,z)
        verify_interior(x,y,z-1)
        verify_interior(x,y,z+1)
    }
}
function adjacent_to_exterior(x,y,z) {
    return (((x-1,y,z) in EXTERIOR) || ((x+1,y,z) in EXTERIOR) ||
            ((x,y-1,z) in EXTERIOR) || ((x,y+1,z) in EXTERIOR) ||
            ((x,y,z-1) in EXTERIOR) || ((x,y,z+1) in EXTERIOR))
}
END {
    if (_exit) {
        exit _exit
    }
    if (DEBUG) print length(CUBES), "cubes, finding exterior"
    for (c in CUBES) {
        split(c, coords, SUBSEP)
        find_adjacent_exterior(coords[1], coords[2], coords[3])
    }
    if (DEBUG) {
        print length(CHECKED), "checked"
        print length(EXTERIOR), "exterior points"
        print length(CHECKED) - (length(EXTERIOR) + length(CUBES)), "interior points"
        print "verifying interior points"
    }
    for (c in CHECKED) if (!(c in CUBES) && !(c in EXTERIOR)) INTERIOR[c] = 1
    for (c in INTERIOR) {
        split(c, coords, SUBSEP)
        if (adjacent_to_exterior(x,y,z)) {
            print "mischaracterized internal point", x, y, z
        }
    }
    if (DEBUG) print "finding exposed sides"
    for (c in CUBES) {
        split(c, coords, SUBSEP)
        exposed += exposed_sides(coords[1], coords[2], coords[3])
    }
    print exposed
}
