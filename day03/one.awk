#!/usr/bin/env awk -f
BEGIN {
    split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", item_types, "")
    for (i in item_types) {
        priority[item_types[i]] = i
    }
    sum = 0
}
{
    compartment_size = length($0) / 2
    if (compartment_size != int(compartment_size)) {
        print "DATA ERROR"
        exit _exit=1
    }
    first_compartment = substr($0, 1, compartment_size)
    second_compartment = substr($0, compartment_size + 1, compartment_size)
    split("", matches)
    for (i = 1; i <= compartment_size; ++i) {
        item_type = substr(first_compartment, i, 1)
        if (index(second_compartment, item_type)) {
            matches[item_type] = priority[item_type]
        }
    }
    # print first_compartment, second_compartment
    for (item_type in matches) {
        sum += matches[item_type]
        # print item_type, matches[item_type]
    }
}
END {
    if (_exit) {
        exit _exit
    }
    print sum
}
