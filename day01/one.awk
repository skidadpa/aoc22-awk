#!/usr/bin/env awk -f
BEGIN {
    elf = 1
}
/^\s*$/ {
    ++elf
    next
}
{
    calories[elf] += $1
}
END {
    largest = calories[1]
    for (elf in calories) {
        if (calories[elf] > largest) {
            largest = calories[elf]
        }
    }
    print largest
}
