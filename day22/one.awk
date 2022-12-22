#!/usr/bin/env awk -f
BEGIN {
    WIDTH = 0
    reading_map = 1
    reading_path = 0
    RIGHT = 0
    DOWN = 1
    LEFT = 2
    UP = 3
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
function leftmost_at(row,   i) {
    for (i = 1; i <= WIDTH; ++i) {
        if (i in MAP[row]) {
            return i
        }
    }
    print "PROCESSING ERROR finding leftmost at", row
    exit _exit=1
}
function rightmost_at(row,   i) {
    for (i = WIDTH; i >= 1; --i) {
        if (i in MAP[row]) {
            return i
        }
    }
    print "PROCESSING ERROR finding rightmost at", row
    exit _exit=1
}
function topmost_at(col,   i) {
    for (i = 1; i <= HEIGHT; ++i) {
        if (col in MAP[i]) {
            return i
        }
    }
    print "PROCESSING ERROR finding topmost at", col
    exit _exit=1
}
function bottommost_at(col,   i) {
    for (i = HEIGHT; i >= 1; --i) {
        if (col in MAP[i]) {
            return i
        }
    }
    print "PROCESSING ERROR finding bottommost at", col
    exit _exit=1
}
function movex(ox, oy, dir,   nx) {
    switch (dir) {
    case 0:
        nx = ox + 1
        if (!(nx in MAP[oy])) {
            nx = leftmost_at(oy)
        }
        if (MAP[oy][nx] == "#") {
            return ox
        } else if (MAP[oy][nx] == ".") {
            return nx
        }
        break
    case 2:
        nx = ox - 1
        if (!(nx in MAP[oy])) {
            nx = rightmost_at(oy)
        }
        if (MAP[oy][nx] == "#") {
            return ox
        } else if (MAP[oy][nx] == ".") {
            return nx
        }
        break
    case 1:
    case 3:
        return ox
    }
    print "PROCESSING ERROR moving x in direction", dir
    exit _exit=1
}
function movey(ox, oy, dir,   ny) {
    switch (dir) {
    case 1:
        ny = oy + 1
        if ((ny > HEIGHT) || !(ox in MAP[ny])) {
            ny = topmost_at(ox)
        }
        if (MAP[ny][ox] == "#") {
            return oy
        } else if (MAP[ny][ox] == ".") {
            return ny
        }
        break
    case 3:
        ny = oy - 1
        if ((ny < 1) || !(ox in MAP[ny])) {
            ny = bottommost_at(ox)
        }
        if (MAP[ny][ox] == "#") {
            return oy
        } else if (MAP[ny][ox] == ".") {
            return ny
        }
        break
    case 0:
    case 2:
        return oy
    }
    print "PROCESSING ERROR moving y in direction", dir
    exit _exit=1
}
/^$/ {
    if (!reading_map || reading_path) {
        print "DATA ERROR"
        exit _exit=1
    }
    HEIGHT = NR - 1
    reading_map = 0
    reading_path = 1
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
    if (DEBUG) print NF, "instructions for map of height", HEIGHT, "and width", WIDTH
    x = leftmost_at(1)
    y = 1
    direction = RIGHT
    if (DEBUG) print "starting at", x, y, direction
    for (p = 1; p <= NF; ++p) {
        if (DEBUG) print "moving", $p
        if ($p == "L") {
            direction = TURN_LEFT[direction]
            if (DEBUG) print "turn left, new direction is", direction
        } else if ($p == "R") {
            direction = TURN_RIGHT[direction]
            if (DEBUG) print "turn left, new direction is", direction
        } else {
            for (i = 1; i <= $p; ++i) {
                x = movex(x, y, direction)
                y = movey(x, y, direction)
            }
            if (DEBUG) print "move by", $p, "end at", x, y, direction
        }
    }
    print 1000 * y + 4 * x + direction
}
END {
    if (_exit) {
        exit _exit
    }
}
