#!/usr/bin/env awk -f
BEGIN {
    WIDTH = 0
    reading_map = 1
    reading_path = 0
    RIGHT = 0
    DOWN = 1
    LEFT = 2
    UP = 3
    DIRS[RIGHT] = "RIGHT"
    DIRS[DOWN] = "DOWN"
    DIRS[LEFT] = "LEFT"
    DIRS[UP] = "UP"
    TURN_RIGHT[RIGHT] = DOWN
    TURN_RIGHT[DOWN] = LEFT
    TURN_RIGHT[LEFT] = UP
    TURN_RIGHT[UP] = RIGHT
    TURN_LEFT[RIGHT] = UP
    TURN_LEFT[UP] = LEFT
    TURN_LEFT[LEFT] = DOWN
    TURN_LEFT[DOWN] = RIGHT
    DEBUG = 0
}
/^$/ {
    if (!reading_map || reading_path) {
        print "DATA ERROR in read state"
        exit _exit=1
    }
    HEIGHT = NR - 1
    reading_map = 0
    reading_path = 1
    if ((HEIGHT == 12) && (WIDTH = 16)) {
        F = 4
    } else if ((HEIGHT == 200) && (WIDTH = 150)) {
        F = 50
    } else {
        print "DATA ERROR unrecognized size", HEIGHT, WIDTH
        exit _exit=1
    }
    FPAT = "([LR])|([[:digit:]]+)"
    next
}
(reading_map) {
    w = split($0,ROW,"")
    if (WIDTH < w) {
        WIDTH = w
    }
    for (c in ROW) {
        if (ROW[c] != " ") {
            MAP[NR][c] = ROW[c]
        }
    }
}
(reading_path) {
    if (DEBUG) print NF, "instructions for map with face size", F
    if (F == 4) {
        x = 2 * F + 1
        y = 1
        dir = RIGHT
        if (DEBUG) print "starting at", x, y, DIRS[dir]
        for (p = 1; p <= NF; ++p) {
            if ($p == "L") {
                dir = TURN_LEFT[dir]
                if (DEBUG) print "turn left, new direction is", DIRS[dir]
            } else if ($p == "R") {
                dir = TURN_RIGHT[dir]
                if (DEBUG) print "turn right, new direction is", DIRS[dir]
            } else {
                for (i = 1; i <= $p; ++i) {
                    switch (dir) {
                    case 0: # RIGHT
                        nx = x + 1
                        if (nx in MAP[y]) {
                            ny = y
                            ndir = dir
                        } else {
                            if (y <= F) {
                                nx = 4 * F
                                ny = 3 * F + 1 - y
                                ndir = LEFT
                            } else if (y <= 2 * F) {
                                nx = 5 * F + 1 - y
                                ny = 2 * F + 1
                                ndir = DOWN
                            } else { # y > 2 * F
                                nx = 3 * F
                                ny = 3 * F + 1 - y
                                ndir = LEFT
                            }
                        }
                        break
                    case 1: # DOWN
                        ny = y + 1
                        if ((ny <= HEIGHT) && (x in MAP[ny])) {
                            nx = x
                            ndir = dir
                        } else {
                            if (x <= F) {
                                nx = 3 * F + 1 - x
                                ny = 3 * F
                                ndir = UP
                            } else if (x <= 2 * F) {
                                nx = 2 * F + 1
                                ny = 4 * F + 1 - x
                                ndir = RIGHT
                            } else if (x <= 3 * F) {
                                nx = 3 * F + 1 - x
                                ny = 2 * F
                                ndir = UP
                            } else { # y > 3 * F
                                nx = 1
                                ny = 5 * F + 1 - x
                                ndir = RIGHT
                            }
                        }
                        break
                    case 2: # LEFT
                        nx = x - 1
                        if (nx in MAP[y]) {
                            ny = y
                            ndir = dir
                        } else {
                            if (y <= F) {
                                nx = F + y
                                ny = F + 1
                                ndir = DOWN
                            } else if (y <= 2 * F) {
                                nx = 5 * F + 1 - y
                                ny = 3 * F
                                ndir = UP
                            } else { # y > 2 * F
                                nx = 4 * F + 1 - y
                                ny = 2 * F
                                ndir = UP
                            }
                        }
                        break
                    case 3: # UP
                        ny = y - 1
                        if ((ny >= 1) && (x in MAP[ny])) {
                            nx = x
                            ndir = dir
                        } else {
                            if (x <= F) {
                                nx = 3 * F + 1 - x
                                ny = 1
                                ndir = DOWN
                            } else if (x <= 2 * F) {
                                nx = 2 * F + 1
                                ny = x - F
                                ndir = RIGHT
                            } else if (x <= 3 * F) {
                                nx = 3 * F + 1 - x
                                ny = F
                                ndir = DOWN
                            } else { # y > 3 * F
                                nx = 3 * F
                                ny = 5 * F + 1 - x
                                ndir = LEFT
                            }
                        }
                        break
                    }
                    if (MAP[ny][nx] == ".") {
                        x = nx
                        y = ny
                        dir = ndir
                    } else if (MAP[ny][nx] != "#") {
                        print "PROCESSING ERROR at", x, y, DIRS[dir], "=>", nx, ny, DIRS[ndir]
                        exit _exit=1
                    }
                }
                if (DEBUG) print "move", $p, "to", x, y, DIRS[dir]
            }
        }
    } else if (F == 50) {
        x = F + 1
        y = 1
        dir = RIGHT
        if (DEBUG) print "starting at", x, y, DIRS[dir]
        for (p = 1; p <= NF; ++p) {
            if ($p == "L") {
                dir = TURN_LEFT[dir]
                if (DEBUG) print "turn left, new direction is", DIRS[dir]
            } else if ($p == "R") {
                dir = TURN_RIGHT[dir]
                if (DEBUG) print "turn right, new direction is", DIRS[dir]
            } else {
                for (i = 1; i <= $p; ++i) {
                    switch (dir) {
                    case 0: # RIGHT
                        nx = x + 1
                        if (nx in MAP[y]) {
                            ny = y
                            ndir = dir
                        } else {
                            if (y <= F) {
                                nx = 2 * F
                                ny = 3 * F + 1 - y
                                ndir = LEFT
                            } else if (y <= 2 * F) {
                                nx = F + y
                                ny = F
                                ndir = UP
                            } else if (y <= 3 * F) {
                                nx = 3 * F
                                ny = 3 * F + 1 - y
                                ndir = LEFT
                            } else { # y > 3 * F
                                nx = y - 2 * F
                                ny = 3 * F
                                ndir = UP
                            }
                        }
                        break
                    case 1: # DOWN
                        ny = y + 1
                        if ((ny <= HEIGHT) && (x in MAP[ny])) {
                            nx = x
                            ndir = dir
                        } else {
                            if (x <= F) {
                                nx = 2 * F + x
                                ny = 1
                                ndir = DOWN
                            } else if (x <= 2 * F) {
                                nx = F
                                ny = 2 * F + x
                                ndir = LEFT
                            } else { # y > 2 * F
                                nx = 2 * F
                                ny = x - F
                                ndir = LEFT
                            }
                        }
                        break
                    case 2: # LEFT
                        nx = x - 1
                        if (nx in MAP[y]) {
                            ny = y
                            ndir = dir
                        } else {
                            if (y <= F) {
                                nx = 1
                                ny = 3 * F + 1 - y
                                ndir = RIGHT
                            } else if (y <= 2 * F) {
                                nx = y - F
                                ny = 2 * F + 1
                                ndir = DOWN
                            } else if (y <= 3 * F) {
                                nx = F + 1
                                ny = 3 * F + 1 - y
                                ndir = RIGHT
                            } else { # y > 3 * F
                                nx = y - 2 * F
                                ny = 1
                                ndir = DOWN
                            }
                        }
                        break
                    case 3: # UP
                        ny = y - 1
                        if ((ny >= 1) && (x in MAP[ny])) {
                            nx = x
                            ndir = dir
                        } else {
                            if (x <= F) {
                                nx = F + 1
                                ny = F + x
                                ndir = RIGHT
                            } else if (x <= 2 * F) {
                                nx = 1
                                ny = 2 * F + x
                                ndir = RIGHT
                            } else { # y > 2 * F
                                nx = x - 2 * F
                                ny = 4 * F
                                ndir = UP
                            }
                        }
                        break
                    }
                    if ((y in MAP) && (nx in MAP[ny]) && (MAP[ny][nx] == ".")) {
                        x = nx
                        y = ny
                        dir = ndir
                    } else if (!(ny in MAP) || !(nx in MAP[ny])) {
                        print "PROCESSING ERROR at", x, y, DIRS[dir], "=>", nx, ny, DIRS[ndir], "not in map"
                        exit _exit=1
                    } else if (MAP[ny][nx] != "#") {
                        print "PROCESSING ERROR at", x, y, DIRS[dir], "=>", nx, ny, DIRS[ndir], "[", MAP[ny][nx], "]"
                        exit _exit=1
                    }
                }
                if (DEBUG) print "move", $p, "to", x, y, DIRS[dir]
            }
        }
    }
    print 1000 * y + 4 * x + dir
}
END {
    if (_exit) {
        exit _exit
    }
}
