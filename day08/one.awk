#!/usr/bin/env awk -f
{
    split($0, row[NR], "")
    if (NC && (NC != length($0))) {
        print "DATA ERROR"
        exit _exit=1
    }
    NC = length($0)
}
function check_visibility(r, c,   i) {
    height = row[r][c]
    for (i = c - 1; i >= 1; --i) { if (row[r][i] >= height) break }
    if (i < 1) {
        visible[r][c] = 1
        return
    }
    for (i = c + 1; i <= NC; ++i) { if (row[r][i] >= height) break }
    if (i > NC) {
        visible[r][c] = 1
        return
    }
    for (i = r - 1; i >= 1; --i) { if (row[i][c] >= height) break }
    if (i < 1) {
        visible[r][c] = 1
        return
    }
    for (i = r + 1; i <= NR; ++i) { if (row[i][c] >= height) break }
    if (i > NR) {
        visible[r][c] = 1
    }
}
END {
    if (_exit) {
        exit _exit
    }
    for (r in row) {
        for (c in row[r]) {
            check_visibility(r, c)
        }
    }
    for (r in visible) {
        count += length(visible[r])
    }
    print count
}
