#!/usr/bin/env awk -f
BEGIN {
    split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", item_types, "")
    for (i in item_types) {
        priority[item_types[i]] = i
    }
    sum = 0
    elf = 0
}
{
    rucksack[++elf] = $0
}
(elf > 2) {
    split("", match_1_2)
    for (i = 1; i <= length(rucksack[1]); ++i) {
        item_type = substr(rucksack[1], i, 1)
        if (index(rucksack[2], item_type)) {
            match_1_2[item_type] = 1
        }
    }
    split("", match_all)
    for (item_type in match_1_2) {
        if (index(rucksack[3], item_type)) {
            match_all[item_type] = priority[item_type]
        }
    }
    if (length(match_all) != 1) {
        print "DATA ERROR"
        exit _exit=1
    }
    for (item_type in match_all) {
        sum += match_all[item_type]
    }
    elf = 0
}
END {
    if (_exit) {
        exit _exit
    }
    if (elf) {
        print "DATA ERROR"
        exit _exit=1
    }
    print sum
}
