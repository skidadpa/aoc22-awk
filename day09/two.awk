#!/usr/bin/env awk -f
function draw_map(   i, ix, iy, MAP) {
    for (ix = xmin; ix <= xmax; ++ix) {
        for (yx = ymin; yx <= ymax; ++yx) {
            MAP[ix,yx] = "."
        }
    }
    MAP[0,0] = "s"
    MAP[x[TAIL],y[TAIL]] = "T"
    for (i = TAIL - 1; i > HEAD; --i) {
        MAP[x[i],y[i]] = "" i
    }
    MAP[x[HEAD],y[HEAD]] = "H"
    for (yx = ymax; yx >= ymin; --yx) {
        for (ix = xmin; ix <= xmax; ++ix) {
            printf("%c",MAP[ix,yx])
        }
        printf("\n")
    }
    printf("\n")
}
BEGIN {
    HEAD = 0
    TAIL = 9
    for (i = HEAD; i <= TAIL; ++i) {
        x[i] = y[i] = 0
    }
    VISITED[x[TAIL],y[TAIL]] = 1
    DEBUG = 0
    if (DEBUG) {
        xmin = xmax = ymin = ymax = 0
        draw_map()
    }
}
function move_next_segment(cur,  nxt) {
    nxt = cur + 1
    if (x[cur] == x[nxt]) {
        if (y[cur] - y[nxt] > 1) {
            ++y[nxt]
        } else if (y[nxt] - y[cur] > 1) {
            --y[nxt]
        }
    } else if (y[cur] == y[nxt]) {
        if (x[cur] - x[nxt] > 1) {
            ++x[nxt]
        } else if (x[nxt] - x[cur] > 1) {
            --x[nxt]
        }
    } else if ((y[cur] > y[nxt]) && (x[cur] > x[nxt])) {
        if ((y[cur] - y[nxt] > 1) || (x[cur] - x[nxt] > 1)) {
            ++y[nxt]
            ++x[nxt]
        }
    } else if ((y[nxt] > y[cur]) && (x[nxt] > x[cur])) {
        if ((y[nxt] - y[cur] > 1) || (x[nxt] - x[cur] > 1)) {
            --y[nxt]
            --x[nxt]
        }
    } else if ((y[cur] > y[nxt]) && (x[nxt] > x[cur])) {
        if ((y[cur] - y[nxt] > 1) || (x[nxt] - x[cur] > 1)) {
            ++y[nxt]
            --x[nxt]
        }
    } else if ((y[nxt] > y[cur]) && (x[cur] > x[nxt])) {
        if ((y[nxt] - y[cur] > 1) || (x[cur] - x[nxt] > 1)) {
            --y[nxt]
            ++x[nxt]
        }
    } else {
        print "PROCESSING ERROR"
        exit _exit=1
    }
}
function move_rope(  i) {
    if (DEBUG) {
        if (xmax < x[HEAD]) xmax = x[HEAD]
        if (xmin > x[HEAD]) xmin = x[HEAD]
        if (ymax < y[HEAD]) ymax = y[HEAD]
        if (ymin > y[HEAD]) ymin = y[HEAD]
    }
    for (i = HEAD; i < TAIL; ++i) {
        move_next_segment(i)
    }
    ++VISITED[x[TAIL],y[TAIL]]
}
/^R [[:digit:]]+$/ {
    for (i = 1; i <= $2; ++i) {
        ++x[HEAD]
        move_rope()
    }
    if (DEBUG) {
        draw_map()
    }
    next
}
/^U [[:digit:]]+$/ {
    for (i = 1; i <= $2; ++i) {
        ++y[HEAD]
        move_rope()
    }
    if (DEBUG) {
        draw_map()
    }
    next
}
/^L [[:digit:]]+$/ {
    for (i = 1; i <= $2; ++i) {
        --x[HEAD]
        move_rope()
    }
    if (DEBUG) {
        draw_map()
    }
    next
}
/^D [[:digit:]]+$/ {
    for (i = 1; i <= $2; ++i) {
        --y[HEAD]
        move_rope()
    }
    if (DEBUG) {
        draw_map()
    }
    next
}
{
    print "DATA ERROR"
    exit _exit=1
}
END {
    if (_exit) {
        exit _exit
    }
    print length(VISITED)
}
