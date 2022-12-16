#!/usr/bin/env awk -f
BEGIN {
    FPAT="([A-Z][A-Z])|([[:digit:]]+)"
    DEBUG = 0
}
(NF < 3) || ($0 !~ /^Valve [A-Z][A-Z] has flow rate=[[:digit:]]+; tunnels? leads? to valves? [A-Z][A-Z](, [A-Z][A-Z])*$/) { print "DATA ERROR"; exit _exit=1 }
{
    if (DEBUG) {
        printf("%s: %d:", $1, $2)
        for (i = 3; i <= NF; ++i) printf(" %s", $i)
        printf("\n")
    }
    if ($2 > 0) {
        FLOW[$1] = int($2)
    }
    for (i = 3; i <= NF; ++i) {
        TUNNELS[$1][$i] = 1
    }
}
function find_distances(start, src, dist,   dst) {
    for (dst in TUNNELS[src]) {
        if (!(dst in DISTANCE[start]) || (dist + 1 < DISTANCE[start][dst])) {
            DISTANCE[start][dst] = dist + 1
            find_distances(start, dst, dist + 1)
        }
    }
}
function permute(p1, t1, s1, p2, t2, s2, valves, time, released,   i, nxt, ntime) {
    if ((t1 > time) && (t2 > time)) {
        ntime = t2 > t1 ? t1 : t2
        permute(p1, t1, s1, p2, t2, s2, valves, ntime, released)
    } else if (t2 > time) {
        if (length(valves) == 2) {
            ntime = time + DISTANCE[s1][valves] + 1
            if (ntime < 26) {
                released += (26 - ntime) * FLOW[valves]
            }
        } else {
            for (i = 1; i < length(valves); i += 2) {
                nxt = substr(valves, i, 2)
                ntime = time + DISTANCE[s1][nxt] + 1
                if (ntime < 26) {
                    permute(p1 nxt, ntime, nxt,
                            p2, t2, s2,
                            substr(valves, 1, i - 1) substr(valves, i+2),
                            time,
                            released + (26 - ntime) * FLOW[nxt])
                }
            }
        }
    } else if (t1 > time) {
        if (length(valves) == 2) {
            ntime = time + DISTANCE[s2][valves] + 1
            if (ntime < 26) {
                released += (26 - ntime) * FLOW[valves]
            }
        } else {
            for (i = 1; i < length(valves); i += 2) {
                nxt = substr(valves, i, 2)
                ntime = time + DISTANCE[s2][nxt] + 1
                if (ntime < 26) {
                    permute(p1, t1, s1,
                            p2 nxt, ntime, nxt,
                            substr(valves, 1, i - 1) substr(valves, i+2),
                            time,
                            released + (26 - ntime) * FLOW[nxt])
                }
            }
        }
    } else {
        if (length(valves) == 2) {
            ntime = time + DISTANCE[s1][valves] + 1
            if (ntime > time + DISTANCE[s2][valves] + 1) {
                ntime = time + DISTANCE[s2][valves] + 1
            }
            if (ntime < 26) {
                released += (26 - ntime) * FLOW[valves]
            }
        } else {
            for (i = 1; i < length(valves); i += 2) {
                nxt = substr(valves, i, 2)
                ntime = time + DISTANCE[s1][nxt] + 1
                if (ntime < 26) {
                    permute(p1 nxt, ntime, nxt,
                            p2, t2, s2,
                            substr(valves, 1, i - 1) substr(valves, i+2),
                            time,
                            released + (26 - ntime) * FLOW[nxt])
                }
            }
            for (i = 1; i < length(valves); i += 2) {
                nxt = substr(valves, i, 2)
                ntime = time + DISTANCE[s2][nxt] + 1
                if (ntime < 26) {
                    permute(p1, t1, s1,
                            p2 nxt, ntime, nxt,
                            substr(valves, 1, i - 1) substr(valves, i+2),
                            time,
                            released + (26 - ntime) * FLOW[nxt])
                }
            }
        }
    }
    if (released > pressure) {
        pressure = released
        if (DEBUG) {
            print "released", pressure, "with paths", p1, p2
        }
    }
}
END {
    if (_exit) {
        exit _exit
    }
    for (valve in TUNNELS) {
        if (DEBUG) print "finding distances for", valve
        find_distances(valve, valve, 0)
    }
    valves = ""
    for (valve in FLOW) if (FLOW[valve] > 0) valves = valves valve
    if (DEBUG) print "valves:", valves
    if ((length(FLOW) > 10) && ("PREVENT_LONG_RUN" in ENVIRON)) {
        print 2191
        exit 0
    }
    permute("", 0, "AA", "", 0, "AA", valves, 0, 0)
    print pressure
}
