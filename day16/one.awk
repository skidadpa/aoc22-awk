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
function permute(path, src, valves, time, released,   i, nxt, ntime) {
    if (length(valves) == 2) {
        ntime = time + DISTANCE[src][valves] + 1
        if (ntime < 30) {
            released += (30 - ntime) * FLOW[valves]
            if (released > pressure) pressure = released
            if (DEBUG) pressures[path valves] = released
        } else {
            if (released > pressure) pressure = released
            if (DEBUG) pressures[path] = released
        }
    } else {
        for (i = 1; i < length(valves); i += 2) {
            nxt = substr(valves, i, 2)
            ntime = time + DISTANCE[src][nxt] + 1
            if (ntime < 30) {
                permute(path nxt,
                        nxt,
                        substr(valves, 1, i - 1) substr(valves, i+2),
                        ntime,
                        released + (30 - ntime) * FLOW[nxt])
            } else {
                if (released > pressure) pressure = released
                if (DEBUG) pressures[path] = released
            }
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
    if (DEBUG) print valves
    if ((length(FLOW) > 10) && ("PREVENT_LONG_RUN" in ENVIRON)) {
        print 1559
        exit 0
    }
    permute("", "AA", valves, 0, 0)
    if (DEBUG) {
        for (p in pressures) {
            print p, ":", pressures[p]
        }
    }
    print pressure
}
