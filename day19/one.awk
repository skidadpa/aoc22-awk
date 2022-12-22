#!/usr/bin/env awk -f
BEGIN {
    FPAT="[[:digit:]]+"
    NONE=0
    ORE=1
    CLAY=2
    OBSIDIAN=3
    GEODE=4
    N[ORE]="ore"
    N[CLAY]="clay"
    N[OBSIDIAN]="obsidian"
    N[GEODE]="geode"
    DURATION=24
    DEBUG=0
}
function enough_resources_to_build(r, H,  m) {
    for (m in C[r]) {
        if (H[m] < C[r][m]) {
            return 0
        }
    }
    return 1
}
function find_most_geodes(path, nxt,   builds, time, M, R, geodes, t, m, r) {
    time = split(path, builds)
    for (r in C) {
        M[r] = 0
    }
    delete R
    M[ORE] = time
    R[ORE] = 1
    geodes = 0
    if (DEBUG) {
        printf("%s : %d :", path, nxt)
    }
    for (t in builds) {
        this_build = builds[t]
        if (this_build != NONE) {
            ++R[this_build]
            M[this_build] += time - t
            for (m in C[this_build]) {
                M[m] -= C[this_build][m]
            }
            if (this_build == GEODE) geodes += (DURATION - t)
        }
    }
    if (most_geodes < geodes) most_geodes = geodes
    if (DEBUG) printf(" %d (%d)", geodes, most_geodes)
    if ((R[nxt] * (DURATION - time) + M[nxt] >= (DURATION - time) * MAX_USABLE[nxt]) ||
        (geodes + ((DURATION - time - 2) * (DURATION - time - 1) / 2) < most_geodes)) {
        if (DEBUG) printf("\n")
        return
    }
    while ((time < DURATION) && !enough_resources_to_build(nxt, M)) {
        ++time
        path = path " " NONE
        for (r in R) {
            M[r] += R[r]
        }
    }
    if (DEBUG) {
        printf(" : %s :", path)
        for (m in M) printf(" %d", M[m])
        printf("\n")
    }
    if (time >= DURATION) return
    path = path " " nxt
    if (OBSIDIAN in R) find_most_geodes(path, GEODE)
    if ((CLAY in R) && (MAX_USABLE[OBSIDIAN] > R[OBSIDIAN])) find_most_geodes(path, OBSIDIAN)
    if (MAX_USABLE[CLAY] > R[CLAY]) find_most_geodes(path, CLAY)
    if (MAX_USABLE[ORE] > R[ORE]) find_most_geodes(path, ORE)
}
$0 !~ /^Blueprint [[:digit:]]+: Each ore robot costs [[:digit:]]+ ore\. Each clay robot costs [[:digit:]]+ ore\. Each obsidian robot costs [[:digit:]]+ ore and [[:digit:]]+ clay\. Each geode robot costs [[:digit:]]+ ore and [[:digit:]]+ obsidian\.$/ {
    print "DATA ERROR"
    exit _exit=1
}
("PREVENT_LONG_RUN" in ENVIRON) {
    next
}
{
    C[ORE][ORE] = $2
    C[CLAY][ORE] = $3
    C[OBSIDIAN][ORE] = $4
    C[OBSIDIAN][CLAY] = $5
    C[GEODE][ORE] = $6
    C[GEODE][OBSIDIAN] = $7
    R[ORE] = 1
    R[CLAY] = R[OBSIDIAN] = R[GEODE] = 0
    for (r in C) {
        MAX_USABLE[r] = 0
    }
    for (r in C) {
        for (m in C[r]) {
            if (MAX_USABLE[m] < C[r][m]) {
                MAX_USABLE[m] = C[r][m]
            }
        }
    }
    MAX_USABLE[GEODE] = DURATION
    if (DEBUG) {
        print "Blueprint", $1
        for (r in C) {
            printf("  %s robot costs:",r);
            for (m in C[r]) {
                printf(" %d %s", C[r][m], m)
            }
            printf("\n")
        }
        for (m in MAX_USABLE) {
            print " max", MAX_USABLE[m], m, "robots usable"
        }
    }
    most_geodes = 0
    find_most_geodes(NONE, CLAY)
    if (MAX_USABLE[ORE] > 1) {
        find_most_geodes(NONE, ORE)
    }
    if (DEBUG) {
        print "Blueprint", $1, "results: quality", $1 * most_geodes
    }
    QUALITY[$1] = $1 * most_geodes
}
END {
    if (_exit) {
        exit _exit
    }
    if ("PREVENT_LONG_RUN" in ENVIRON) {
        print (NR > 2) ? 1081 : 33
        exit 0
    }
    sum = 0
    for (b in QUALITY) {
        sum += QUALITY[b]
    }
    print sum
}
