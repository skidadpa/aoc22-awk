#!/usr/bin/env awk -f
BEGIN {
    DEBUG = 0
    NUM_ROCKS = DEBUG ? 11 : 2022
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
       if (DEBUG) {
           print "new block of type", block
           draw_map_with_block(block, x, y, top)
       }
       falling = 1
       while (falling) {
           direction = gusts[gust]
           gust = (gust + 1) % num_gusts
           if (can_move(block, x + direction, y)) x += direction
           if (DEBUG) {
               print "jet of gas to", (direction < 0) ? "left" : "right"
               draw_map_with_block(block, x, y, top)
           }
           falling = can_move(block, x, y - 1)
           if (falling) y -= 1
           if (DEBUG) {
               print "rock falls 1 unit"
               draw_map_with_block(block, x, y, top)
           }
       }
       top = add_to_map(block, top, x, y, "#")
       if (DEBUG) {
           print "rock settles"
           draw_map(top)
       }
       block = (block + 1) % 5
   }
   print top
}
END { if (_exit) exit _exit }
