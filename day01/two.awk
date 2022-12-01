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
    n = asort(calories, largest, "@val_num_desc")
    if (n < 3) { print "ERROR: illegal data"; exit 1 }
    print largest[1] + largest[2] + largest[3]
}
