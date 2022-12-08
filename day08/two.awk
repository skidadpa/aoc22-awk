#!/usr/bin/env awk -f
{
    split($0, row[NR], "")
    if (NC && (NC != length($0))) {
        print "DATA ERROR"
        exit _exit=1
    }
    NC = length($0)
}
function compute_scenic_score(r, c,   i, n, s, e, w) {
    height = row[r][c]
    for (i = c - 1; i >= 1; --i) { ++w; if (row[r][i] >= height) break }
    for (i = c + 1; i <= NC; ++i) { ++e; if (row[r][i] >= height) break }
    for (i = r - 1; i >= 1; --i) { ++n; if (row[i][c] >= height) break }
    for (i = r + 1; i <= NR; ++i) { ++s; if (row[i][c] >= height) break }
    score[r][c] = n * s * e * w
}
END {
    if (_exit) {
        exit _exit
    }
    for (r in row) {
        for (c in row[r]) {
            compute_scenic_score(r, c)
        }
    }
    for (r in score) {
        for (c in score[r]) {
            if (score[r][c] > best) {
                best = score[r][c]
            }
        }
    }
    print best
}
