#!/usr/bin/env awk -f
BEGIN {
    FS = ","
}
(NF != 3) || ($0 !~ /^[[:digit:]]+,[[:digit:]]+,[[:digit:]]+$/) {
    print "DATA ERROR"
    exit _exit=1
}
{
    CUBES[$1,$2,$3] = 1
}
function exposed_sides(x, y, z,   count) {
    count = 0
    if (!((x-1,y,z) in CUBES)) ++count
    if (!((x+1,y,z) in CUBES)) ++count
    if (!((x,y-1,z) in CUBES)) ++count
    if (!((x,y+1,z) in CUBES)) ++count
    if (!((x,y,z-1) in CUBES)) ++count
    if (!((x,y,z+1) in CUBES)) ++count
    return count
}
END {
    if (_exit) {
        exit _exit
    }
    for (c in CUBES) {
        split(c, coords, SUBSEP)
        exposed += exposed_sides(coords[1], coords[2], coords[3])
    }
    print exposed
}
