#!/usr/bin/env awk -f
BEGIN {
    DEBUG = 0
    NUM_ROCKS = 100000
    split("0 1 2 3", BLOCK_X[0])
    split("0 0 0 0", BLOCK_Y[0])
    split("1 0 1 2 1", BLOCK_X[1])
    split("0 1 1 1 2", BLOCK_Y[1])
    split("0 1 2 2 2", BLOCK_X[2])
    split("0 0 0 1 2", BLOCK_Y[2])
    split("0 0 0 0", BLOCK_X[3])
    split("0 1 2 3", BLOCK_Y[3])
    split("0 1 0 1", BLOCK_X[4])
    split("0 0 1 1", BLOCK_Y[4])
    for (b in BLOCK_X) for (i in BLOCK_X[b]) {
        BLOCK_X[b][i] = int(BLOCK_X[b][i])
        BLOCK_Y[b][i] = int(BLOCK_Y[b][i])
    }
}
function can_move(block, x, y,   i) {
    for (i in BLOCK_X[block]) {
        if ((x+BLOCK_X[block][i],y+BLOCK_Y[block][i]) in MAP) {
            return 0
        }
    }
    return 1
}
function add_to_map(block, top, x, y, ch,   i, block_top) {
    for (i in BLOCK_X[block]) {
        block_top = y+BLOCK_Y[block][i]
        MAP[x+BLOCK_X[block][i],block_top] = ch
    }
    return top > block_top ? top : block_top
}
function remove_from_map(block, x, y,   i) {
    for (i in BLOCK_X[block]) {
        delete MAP[x+BLOCK_X[block][i],y+BLOCK_Y[block][i]]
    }
}
function draw_map(top,   x, y) {
    for (y = top; y >= 0; --y) {
        for (x = 0; x <= 8; ++x) {
            printf("%c", ((x,y) in MAP) ? MAP[x,y] : ".")
        }
        printf("\n")
    }
    printf("\n")
}
function draw_map_with_block(block, x, y, top) {
    top = add_to_map(block, top, x, y, "@")
    draw_map(top)
    remove_from_map(block, x, y)
}
$0 !~ /^[<>]+$/ { print "DATA ERROR"; exit _exit=1 }
{
    delete MAP
    MAP[0,0] = MAP[8,0] = "+"
    for (i = 1; i <= 7; ++i) MAP[i,0] = "-"
    for (i = 1; i <= 5260; ++i) MAP[0,i] = MAP[8,i] = "|"
    delete gusts
    num_gusts = 0
    for (i = 1; i <= length($0); ++i) gusts[num_gusts++] = (substr($0,i,1) == "<" ? -1 : 1)
    block = 0
    gust = 0
    top = 0
    for (r = 1; r <= NUM_ROCKS; ++r) {
        y = top + 4
        x = 3
        falling = 1
        while (falling) {
            direction = gusts[gust]
            gust = (gust + 1) % num_gusts
            if (can_move(block, x + direction, y)) x += direction
            falling = can_move(block, x, y - 1)
            if (falling) y -= 1
        }
        top = add_to_map(block, top, x, y, "#")
        HEIGHTS[r] = top
        top_shape = block "," gust
        for (col = 1; col <= 7; ++col) {
            for (depth = 0; depth <= top; ++depth) {
                if ((col,top-depth) in MAP) break
            }
            top_shape = top_shape "," depth
        }
        if (top_shape in TOPS) {
            break
        }
        TOPS[top_shape] = r
        block = (block + 1) % 5
    }
    if (r >= NUM_ROCKS) {
        print "PROCESSING ERROR"
        exit _exit=1
    }
    start = TOPS[top_shape]
    end = r
    size = end - start
    repeat_height = HEIGHTS[end] - HEIGHTS[start]
    for (i = 0; i < size; ++i) {
        REMAINDER_ADD[i] = HEIGHTS[start + i] - HEIGHTS[start]
    }
    repeat_interval = 1000000000000 - start
    num_repeats = int(repeat_interval / size)
    remainder = repeat_interval % size
    if (DEBUG) {
        print "num gusts", num_gusts
        print "repeat from", start, "to", end, "of shape", top_shape
        print "repeat count", size, "interval", repeat_interval
        print "start height", HEIGHTS[start], "repeat height", repeat_height
        if (DEBUG > 1) {
            for (i = 0; i < size; ++i) {
                print "remainder", i, ":", REMAINDER_ADD[i]
            }
        }
        print "num repeats", num_repeats, "remainder", remainder
    }
    print HEIGHTS[start] + num_repeats * repeat_height + REMAINDER_ADD[remainder]
}
END { if (_exit) exit _exit }
