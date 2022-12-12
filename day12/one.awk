#!/usr/bin/env awk -f
BEGIN {
    num_codes = split("abcdefghijklmnopqrstuvwxyz", elevation_codes, "")
    for (e = 1; e <= num_codes; ++e) {
        elevation[elevation_codes[e]] = e
    }
    DEBUG = 0
}
/S/ {
    S = NR SUBSEP index($0, "S")
    sub("S","a")
}
/E/ {
    E = NR SUBSEP index($0, "E")
    sub("E","z")
}
/^[a-z]+$/ {
    row_width = split($0, row, "")
    if (!width) {
        width = row_width
    }
    if (width != row_width) {
        print "DATA ERROR"
        exit _exit=1
    }
    for (i = 1; i <= width; ++i) {
        MAP[NR,i] = elevation[row[i]]
    }
    next
}
{
    print "DATA ERROR"
    exit _exit=1
}
function print_location(location, ll) {
    split(location, ll, SUBSEP)
    print "row", ll[1], "col", ll[2]
}
function try_these(location, places_to_try,   ll) {
    split(location, ll, SUBSEP)
    split("", places_to_try)
    places_to_try[(ll[1] - 1),ll[2]] = 1
    places_to_try[(ll[1] + 1),ll[2]] = 1
    places_to_try[ll[1],(ll[2] - 1)] = 1
    places_to_try[ll[1],(ll[2] + 1)] = 1
}
function find_moves(from, dist,   places, p) {
    try_these(from, places)
    for (p in places) {
        if ((p in MAP) && (MAP[p] <= MAP[from] + 1) && (!(p in DISTANCE))) {
            DISTANCE[p] = dist
            if (p == E) {
                return 1
            } else {
                MOVES[dist][p] = 1
            }
        }
    }
    return 0
}
END {
    if (_exit) {
        exit _exit
    }
    height = NR
    if (DEBUG) {
        printf("start at ")
        print_location(S)
        printf("end at ")
        print_location(E)
        for (r = 1; r <= height; ++r) {
            for (c = 1; c <= width; ++c) {
                printf("%c", elevation_codes[MAP[r,c]])
            }
            printf("\n")
        }
    }
    DISTANCE[S] = 0
    MOVES[0][S] = 1
    for (last_dist = 0; last_dist < 10000; ++last_dist) {
        dist = last_dist + 1
        if (DEBUG) {
            print "Trying distance of", dist
        }
        for (location in MOVES[last_dist]) {
            if (DEBUG) {
                printf("Moves from ")
                print_location(location)
            }
            if (find_moves(location, dist)) {
                print dist
                exit 0
            }
        }
    }
    print "PROCESSING ERROR"
    exit _exit=1
}
