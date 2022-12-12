#!/usr/bin/env awk -f
BEGIN {
    FS = ":"
    modulo_conversion = 1
    DEBUG = 0
}
(NF == 0) { next }
(NF != 2) {
    print "DATA ERROR wrong number of fields"
    exit _exit=1
}
/Monkey [[:digit:]]+:/ {
    if (match($1, /^Monkey ([[:digit:]]+)$/, monkey_name)) {
        m = int(monkey_name[1])
        MONKEYS[m] = 0
    } else {
        print "DATA ERROR bad Monkey record"
        exit _exit=1
    }
    next
}
/Starting items:/ {
    n = split($2, starting_items, ", ")
    for (i = 1; i <= n; ++i) {
        ITEMS[0][m][i] = int(starting_items[i])
    }
    next
}
/Operation: new = old \+ [[:digit:]]+/ {
    if (match($2, /new = old \+ ([[:digit:]]+)$/, addend)) {
        MULT[m] = 1
        ADD[m] = int(addend[1])
    } else {
        print "DATA ERROR bad addition operation"
        exit _exit=1
    }
    next
}
/Operation: new = old \* [[:digit:]]+/ {
    if (match($2, /new = old \* ([[:digit:]]+)$/, multiplicand)) {
        MULT[m] = int(multiplicand[1])
        ADD[m] = 0
    } else {
        print "DATA ERROR bad multiplication operation"
        exit _exit=1
    }
    next
}
/Operation: new = old \* old/ {
    MULT[m] = 0
    ADD[m] = 0
    next
}
/Test:/ {
    if (match($2, /divisible by ([[:digit:]]+)$/, dividend)) {
        TEST[m] = int(dividend[1])
        modulo_conversion *= TEST[m]
    } else {
        print "DATA ERROR bad test record"
        exit _exit=1
    }
    next
}
/If true:/ {
    if (match($2, /throw to monkey ([[:digit:]]+)$/, monkey_name)) {
        PASS[m] = int(monkey_name[1])
    } else {
        print "DATA ERROR bad test record"
        exit _exit=1
    }
    next
}
/If false:/ {
    if (match($2, /throw to monkey ([[:digit:]]+)$/, monkey_name)) {
        FAIL[m] = int(monkey_name[1])
    } else {
        print "DATA ERROR bad test record"
        exit _exit=1
    }
    next
}
{
    print "DATA ERROR unknown record type"
    exit _exit=1
}
END {
    if (_exit) {
        exit _exit
    }
    if (DEBUG) {
        print "Monkeys:"
        for (m in MONKEYS) {
            print m, MULT[m], ADD[m], TEST[m], PASS[m], FAIL[m]
        }
        print "Starting items:"
        for (m in MONKEYS) {
            printf("%d:", m)
            for (i in ITEMS[0][m]) {
                printf(" %d", ITEMS[0][m][i])
            }
            printf("\n")
        }
    }
    NUM_ROUNDS = 10000
    for (round = 0; round < NUM_ROUNDS; ++round) {
        next_round = round + 1
        if (DEBUG) {
            print "Round", next_round, ":"
        }
        for (m in MONKEYS) {
            split("", ITEMS[next_round][m])
        }
        for (m in MONKEYS) {
            for (i in ITEMS[round][m]) {
                worry = ITEMS[round][m][i]
                if (DEBUG) {
                    print "monkey", m, "inspects item with worry level", worry
                }
                ++MONKEYS[m]
                multiplier = MULT[m] ? MULT[m] : worry
                worry = worry * multiplier + ADD[m]
                # print "worry level changes to", worry
                worry = worry % modulo_conversion
                n = (worry % TEST[m]) ? FAIL[m] : PASS[m]
                if (DEBUG) {
                    print "tosses item with worry level", worry, "to monkey", n
                }
                dest_round = n > m ? round : next_round;
                ITEMS[dest_round][n][length(ITEMS[dest_round][n])+1] = worry
            }
        }
        if (DEBUG) {
            for (m in MONKEYS) {
                printf("%d (%d):", m, MONKEYS[m])
                for (i in ITEMS[next_round][m]) {
                    printf(" %d", ITEMS[next_round][m][i])
                }
                printf("\n")
            }
        }
    }

    # for (m in MONKEYS) {
    #     printf("%d:", m)
    #     for (i in ITEMS[NUM_ROUNDS][m]) {
    #         printf(" %d", ITEMS[NUM_ROUNDS][m][i])
    #     }
    #     printf("\n")
    #     LENS[m] = length(ITEMS[NUM_ROUNDS][m])
    # }
    # asorti(LENS, LONGEST, "@val_num_desc")
    # print "longest:", LENS[LONGEST[1]], LENS[LONGEST[2]]
    # print "by monkeys:", LONGEST[1], LONGEST[2]

    asorti(MONKEYS, LONGEST, "@val_num_desc")
    # print "longest:", MONKEYS[LONGEST[1]], MONKEYS[LONGEST[2]]
    # print "by monkeys:", LONGEST[1], LONGEST[2]
    print MONKEYS[LONGEST[1]] * MONKEYS[LONGEST[2]]
}
