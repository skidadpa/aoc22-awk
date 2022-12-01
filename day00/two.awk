#!/usr/bin/env awk -f
BEGIN {
    largest = 0
}
{
    if ($1 > largest) largest = $1
}
END {
    if (largest > 0) {
        print "The largest natural number seen was", largest
    } else {
        print "No natural numbers seen"
    }
}
