#!/usr/bin/env awk -f
BEGIN {
    PROCINFO["sorted_in"] = "@ind_num_asc"
    DEBUG=0
}
($0 !~ /^-?[[:digit:]]+$/) {
    print "DATA ERROR"
    exit _exit=1
}
/^0$/ {
    ZERO = NR
}
{
    FILE[NR] = int($1)
}
END {
    if (_exit) {
        exit _exit
    }
    for (i in FILE) {
        TAKE_FROM[i] = i
    }
    if (DEBUG) {
        printf("start at:")
        for (i in TAKE_FROM) {
            printf(" %d", FILE[TAKE_FROM[i]])
        }
        printf("\n")
    }
    for (n in FILE) {
        for (old_pos in TAKE_FROM) {
            if (TAKE_FROM[old_pos] == n)
                break
        }
        move_by = FILE[n] % (NR - 1)
        new_pos = old_pos + move_by
        if (move_by < 0) {
            if (new_pos < 1) new_pos += NR
            if (new_pos == 1) new_pos = NR + 1
            new_pos -= 0.5
        } else if (move_by > 0) {
            if (new_pos > NR) new_pos -= NR
            if (new_pos == NR) new_pos = 0
            new_pos += 0.5
        }
        if (DEBUG) {
            printf("move %d from %d to %.1f:", FILE[n], old_pos, new_pos)
            for (i in TAKE_FROM) {
                printf(" %d", FILE[TAKE_FROM[i]])
            }
        }
        if (new_pos != old_pos) {
            delete TAKE_FROM[old_pos]
            TAKE_FROM[new_pos] = n
            asort(TAKE_FROM, TAKE_FROM, "@ind_num_asc")
            if (DEBUG) {
                printf(" =>")
                for (i in TAKE_FROM) {
                    printf(" %d", FILE[TAKE_FROM[i]])
                }
            }
        }
        if (DEBUG) {
            printf("\n")
        }
    }
    if (DEBUG) {
        printf("end at:")
        for (i in TAKE_FROM) {
            printf(" %d", FILE[TAKE_FROM[i]])
        }
        printf("\n")
    }
    for (zero_pos in TAKE_FROM) {
        if (TAKE_FROM[zero_pos] == ZERO)
            break
    }
    cp1 = ((zero_pos - 1) + 1000) % NR + 1
    c1 = FILE[TAKE_FROM[cp1]]
    cp2 = ((zero_pos - 1) + 2000) % NR + 1
    c2 = FILE[TAKE_FROM[cp2]]
    cp3 = ((zero_pos - 1) + 3000) % NR + 1
    c3 = FILE[TAKE_FROM[cp3]]
    if (DEBUG) {
        print "zero at:", zero_pos
        print "coordinates at:", cp1, cp2, cp3
        print "coordinates:", c1, c2, c3
    }
    print c1 + c2 + c3
}
