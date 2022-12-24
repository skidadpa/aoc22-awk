#!/usr/bin/env awk -f
BEGIN {
    LIMIT = 9999
    DEBUG = 0
}
/^#\.#/ {
    STARTED = 1
}
(NF != 1) || (!STARTED) || (FINISHED) {
    print "DATA ERROR"
    exit _exit=1
}
{
    WIDTH = split($1, ROW, "")
    for (c in ROW) {
        switch (ROW[c]) {
        case "#":
            WALLS[c,NR] = 1
            break
        case ".":
            break
        case "^":
            UP[0][c,NR] = 1
            break
        case "v":
            DOWN[0][c,NR] = 1
            break
        case "<":
            LEFT[0][c,NR] = 1
            break
        case ">":
            RIGHT[0][c,NR] = 1
            break
        default:
            print "DATA ERROR"
            exit _exit=1
        }
    }
}
/#\.#$/ {
    FINISHED = 1
}
function print_map(t,   x, y) {
    for (y = 1; y <= NR; ++y) {
        for (x = 1; x <= WIDTH; ++x) {
            count = ((x,y) in UP[t]) + ((x,y) in DOWN[t]) + ((x,y) in LEFT[t]) + ((x,y) in RIGHT[t])
            if (x == playerx && y == playery) {
                printf("E")
            } else if ((x,y) in WALLS) {
                printf("#")
            } else if (count > 1) {
                printf("%d", count)
            } else if ((x,y) in UP[t]) {
                printf("^")
            } else if ((x,y) in DOWN[t]) {
                printf("v")
            } else if ((x,y) in LEFT[t]) {
                printf("<")
            } else if ((x,y) in RIGHT[t]) {
                printf(">")
            } else if ((x,y) in P[t]) {
                printf("E")
            } else {
                printf(".")
            }
        }
        printf("\n")
    }
}
function move_blizzards(t,   i, C, x, y) {
    for (i in UP[t]) {
        split(i, C, SUBSEP)
        x = C[1]
        y = C[2] - 1
        if ((x,y) in WALLS) y = NR - 1
        UP[t+1][x,y] = 1
    }
    for (i in DOWN[t]) {
        split(i, C, SUBSEP)
        x = C[1]
        y = C[2] + 1
        if ((x,y) in WALLS) y = 2
        DOWN[t+1][x,y] = 1
    }
    for (i in LEFT[t]) {
        split(i, C, SUBSEP)
        x = C[1] - 1
        y = C[2]
        if ((x,y) in WALLS) x = WIDTH - 1
        LEFT[t+1][x,y] = 1
    }
    for (i in RIGHT[t]) {
        split(i, C, SUBSEP)
        x = C[1] + 1
        y = C[2]
        if ((x,y) in WALLS) x = 2
        RIGHT[t+1][x,y] = 1
    }
    delete UP[t]
    delete DOWN[t]
    delete LEFT[t]
    delete RIGHT[t]
    for (x = 2; x <= WIDTH - 1; ++x) {
        for (y = 1; y <= NR; ++y) {
            if (!((x,y) in UP[t+1]) && !((x,y) in DOWN[t+1]) && !((x,y) in LEFT[t+1]) && !((x,y) in RIGHT[t+1]) && !((x,y) in WALLS)) {
                if (((x,y) in P[t]) || ((x-1,y) in P[t]) || ((x+1,y) in P[t]) || ((x,y-1) in P[t]) || ((x,y+1) in P[t])) {
                    P[t+1][x,y] = 1
                    if ((x,y) in DEST) return 1
                }
            }
        }
    }
    return 0
}
END {
    if (_exit) {
        exit _exit
    }
    P[0][2,1] = 1
    DEST[WIDTH-1,NR] = 1
    time = 0
    if (DEBUG) {
        print "Initial state:"
        print_map(time)
    }
    while (!move_blizzards(time++)) {
        if (DEBUG) {
            print "At time", time
            print_map(time)
        }
        if (time > LIMIT) {
            print "PROCESSING ERROR, destination not found"
            exit _exit=1
        }
    }
    delete P
    P[time][WIDTH-1,NR] = 1
    delete DEST
    DEST[2,1] = 1
    while (!move_blizzards(time++)) {
        if (DEBUG) {
            print "At time", time
            print_map(time)
        }
        if (time > LIMIT) {
            print "PROCESSING ERROR, destination not found"
            exit _exit=1
        }
    }
    delete P
    P[time][2,1] = 1
    delete DEST
    DEST[WIDTH-1,NR] = 1
    while (!move_blizzards(time++)) {
        if (DEBUG) {
            print "At time", time
            print_map(time)
        }
        if (time > LIMIT) {
            print "PROCESSING ERROR, destination not found"
            exit _exit=1
        }
    }
    if (DEBUG) {
        print "Final state:"
        print_map(time)
    }
    print time
}
