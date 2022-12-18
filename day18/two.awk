#!/usr/bin/env awk -f
BEGIN {
    FS = ","
    XMIN = YMIN = ZMIN = 999
    XMAX = YMAX = ZMAX = -999
    DEBUG = 0
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
function look_for_external(x,y,z) {
    if (!(x,y,z) in CHECKED) {
        EXTERIOR[x,y,z] = 1
        CHECKED[x,y,z] = 1
        look_for_external(x-1,y,z)
        look_for_external(x+1,y,z)
        look_for_external(x,y-1,z)
        look_for_external(x,y+1,z)
        look_for_external(x,y,z-1)
        look_for_external(x,y,z+1)
    }
}
function exposed_sides(x, y, z,   count) {
    count = 0
    if ((x-1,y,z) in EXTERIOR) ++count
    if ((x+1,y,z) in EXTERIOR) ++count
    if ((x,y-1,z) in EXTERIOR) ++count
    if ((x,y+1,z) in EXTERIOR) ++count
    if ((x,y,z-1) in EXTERIOR) ++count
    if ((x,y,z+1) in EXTERIOR) ++count
    return count
}
END {
    if (_exit) {
        exit _exit
    }
    if (DEBUG) print length(CUBES), "cubes, finding exterior in x", XMIN, XMAX, "y", YMIN, YMAX, "z", ZMIN, ZMAX
    for (x = XMIN; x <= XMAX; ++x) for (y = YMIN; y <= YMAX; ++y) { EXTERIOR[x,y,ZMIN-1] = EXTERIOR[x,y,ZMAX+1] = 1 }
    for (x = XMIN; x <= XMAX; ++x) for (z = YMIN; z <= ZMAX; ++z) { EXTERIOR[x,YMIN-1,z] = EXTERIOR[x,YMAX+1,z] = 1 }
    for (y = YMIN; y <= YMAX; ++y) for (z = YMIN; z <= ZMAX; ++z) { EXTERIOR[XMIN-1,y,z] = EXTERIOR[XMAX+1,y,z] = 1 }
    for (c in EXTERIOR) CHECKED[c] = 1
    if (DEBUG) print length(EXTERIOR), "exterior out of", length(CHECKED), "checked points, searching from Z ends"
    for (x = XMIN; x <= XMAX; ++x) for (y = YMIN; y <= YMAX; ++y) {
        look_for_external(x,y,ZMIN)
        look_for_external(x,y,ZMAX)
    }
    if (DEBUG) print length(EXTERIOR), "exterior out of", length(CHECKED), "checked points, searching from Y ends"
    for (x = XMIN; x <= XMAX; ++x) for (z = YMIN; z <= YMAX; ++z) {
        look_for_external(x,YMIN,z)
        look_for_external(x,YMAX,z)
    }
    if (DEBUG) print length(EXTERIOR), "exterior out of", length(CHECKED), "checked points, searching from X ends"
    for (y = YMIN; y <= YMAX; ++y) for (z = YMIN; z <= YMAX; ++z) {
        look_for_external(XMIN,y,z)
        look_for_external(XMAX,y,z)
    }
    if (DEBUG) print length(EXTERIOR), "exterior out of", length(CHECKED), "checked points, finding exposed sides"
    for (c in CUBES) {
        split(c, coords, SUBSEP)
        exposed += exposed_sides(coords[1], coords[2], coords[3])
    }
    print exposed
}
