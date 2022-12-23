#!/usr/bin/env awk -f
BEGIN {
    split("N S W E", MOVES)
    FIRST_MOVE = 1
    LAST_MOVE = length(MOVES)
    CHECK_X["N"][-1] = CHECK_X["S"][-1] = -1
    CHECK_X["N"][0] = CHECK_X["S"][0] = 0
    CHECK_X["N"][1] = CHECK_X["S"][1] = 1
    CHECK_Y["N"][-1] = CHECK_Y["N"][0] = CHECK_Y["N"][1] = -1
    CHECK_Y["S"][-1] = CHECK_Y["S"][0] = CHECK_Y["S"][1] = 1
    CHECK_Y["W"][-1] = CHECK_Y["E"][-1] = -1
    CHECK_Y["W"][0] = CHECK_Y["E"][0] = 0
    CHECK_Y["W"][1] = CHECK_Y["E"][1] = 1
    CHECK_X["W"][-1] = CHECK_X["W"][0] = CHECK_X["W"][1] = -1
    CHECK_X["E"][-1] = CHECK_X["E"][0] = CHECK_X["E"][1] = 1
    NO_MOVE = "X"
    ROUND_LIMIT = 999999
    DEBUG = 0
    if (DEBUG > 2) ROUND_LIMIT = 3
}
function rotate_moves() {
    MOVES[++LAST_MOVE] = MOVES[FIRST_MOVE]
    delete MOVES[FIRST_MOVE++]
}
function compute_bounds(   p, coords) {
    XMIN = YMIN = 99999999
    XMAX = YMAX = -99999999
    for (p in MAP) {
        split(p, coords, SUBSEP)
        if (XMIN > coords[1]) XMIN = coords[1]
        if (XMAX < coords[1]) XMAX = coords[1]
        if (YMIN > coords[2]) YMIN = coords[2]
        if (YMAX < coords[2]) YMAX = coords[2]
    }
    AREA = (XMAX - XMIN + 1) * (YMAX - YMIN + 1)
}
function select_direction(x, y,   i, m) {
    if (((x - 1, y - 1) in MAP) ||
        ((x - 1, y) in MAP) ||
        ((x - 1, y + 1) in MAP) ||
        ((x, y - 1) in MAP) ||
        ((x, y + 1) in MAP) ||
        ((x + 1, y - 1) in MAP) ||
        ((x + 1, y) in MAP) ||
        ((x + 1, y + 1) in MAP)){
        for (i in MOVES) {
            m = MOVES[i]
            if (DEBUG > 2) {
                print "Looking", m, "from", x, y
                print x + CHECK_X[m][-1], y + CHECK_Y[m][-1], ((x + CHECK_X[m][-1], y + CHECK_Y[m][-1]) in MAP) ? "OCCUPIED" : "EMPTY"
                print x + CHECK_X[m][0], y + CHECK_Y[m][0], ((x + CHECK_X[m][0], y + CHECK_Y[m][0]) in MAP) ? "OCCUPIED" : "EMPTY"
                print x + CHECK_X[m][1], y + CHECK_Y[m][1], ((x + CHECK_X[m][1], y + CHECK_Y[m][1]) in MAP) ? "OCCUPIED" : "EMPTY"
            }
            if (!((x + CHECK_X[m][-1], y + CHECK_Y[m][-1]) in MAP) &&
                !((x + CHECK_X[m][0], y + CHECK_Y[m][0]) in MAP) &&
                !((x + CHECK_X[m][1], y + CHECK_Y[m][1]) in MAP)) {
                return m
            }
        }
    }
    return NO_MOVE
}
function round(   e, coords, x, y, dir, PROPOSED_MOVES, DUPLICATES, m, moves) {
    split("", PROPOSED_MOVES)
    split("", DUPLICATES)
    for (e in MAP) {
        split(e, coords, SUBSEP)
        x = int(coords[1])
        y = int(coords[2])
        dir = select_direction(x, y)
        if (DEBUG > 2) print "elf at", x, y, "wants to move in direction", dir
        if (dir != NO_MOVE) {
            x += CHECK_X[dir][0]
            y += CHECK_Y[dir][0]
            if ((x,y) in PROPOSED_MOVES) {
                PROPOSED_MOVES[x,y] = NO_MOVE
                ++DUPLICATES[x,y]
            } else {
                PROPOSED_MOVES[x,y] = e
            }
        }
    }
    if (DEBUG) {
        for (m in MOVES) {
            if (moves == "") moves = "(" MOVES[m]
            else moves = moves " " MOVES[m]
        }
        moves = moves ")"
        print length(PROPOSED_MOVES), "proposed moves", moves, "with", length(DUPLICATES), "duplicates"
    }
    if (DEBUG > 1) {
        compute_bounds()
        for (y = YMIN - 2; y <= YMAX + 2; ++y) {
            for (x = XMIN - 2; x <= XMAX + 2; ++x) {
                if ((x,y) in MAP) printf("#")
                else if ((x,y) in DUPLICATES) printf("0")
                else if ((x,y) in PROPOSED_MOVES) printf("o")
                else printf(".")
            }
            printf("\n")
        }
        printf("\n")
    }
    for (e in PROPOSED_MOVES) {
        if (!(e in DUPLICATES)) {
            MAP[e] = 1
            delete MAP[PROPOSED_MOVES[e]]
        }
    }
    if (DEBUG) {
        compute_bounds()
        for (y = YMIN - 2; y <= YMAX + 2; ++y) {
            for (x = XMIN - 2; x <= XMAX + 2; ++x) {
                if ((x,y) in MAP) printf("#")
                else printf(".")
            }
            printf("\n")
        }
    }
    rotate_moves()
    return (length(PROPOSED_MOVES) == length(DUPLICATES))
}
(!WIDTH) { WIDTH = length($1) }
/[^.#]/ || (NF != 1) || (WIDTH != length($1)) {
    print "DATA ERROR"
    exit _exit=1
}
{
    split($1, row, "")
    for (x in row) {
        if (row[x] == "#") {
            MAP[x,NR] = 1
        }
    }
}
END {
    if (_exit) {
        exit _exit
    }
    ELVES = length(MAP)
    compute_bounds()
    if (DEBUG) {
        print "AT START area =", AREA, "elves =", ELVES, "empty =", (AREA - ELVES)
        compute_bounds()
        for (y = YMIN - 2; y <= YMAX + 2; ++y) {
            for (x = XMIN - 2; x <= XMAX + 2; ++x) {
                if ((x,y) in MAP) printf("#")
                else printf(".")
            }
            printf("\n")
        }
    }
    for (round_number = 1; round_number <= ROUND_LIMIT; ++round_number) {
        if (DEBUG) print "ROUND", round_number
        if (round()) {
            break
        }
        if (DEBUG) {
            compute_bounds()
            print "area =", AREA, "empty =", (AREA - ELVES)
        }
    }
    if (DEBUG) {
        print "AT END area =", AREA, "empty =", (AREA - ELVES)
        compute_bounds()
        for (y = YMIN - 2; y <= YMAX + 2; ++y) {
            for (x = XMIN - 2; x <= XMAX + 2; ++x) {
                if ((x,y) in MAP) printf("#")
                else printf(".")
            }
            printf("\n")
        }
    }
    if (round_number > ROUND_LIMIT) {
        print "PROCESSING ERROR"
        exit _exit=1
    }
    print round_number
}
