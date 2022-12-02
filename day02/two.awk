#!/usr/bin/env awk -f
BEGIN {
    shape["A"] = 1
    shape["B"] = 2
    shape["C"] = 3
    choose["A X"] = "C"
    choose["A Y"] = "A"
    choose["A Z"] = "B"
    choose["B X"] = "A"
    choose["B Y"] = "B"
    choose["B Z"] = "C"
    choose["C X"] = "B"
    choose["C Y"] = "C"
    choose["C Z"] = "A"
    outcome["X"] = 0
    outcome["Y"] = 3
    outcome["Z"] = 6
}
{
    score += shape[choose[$0]] + outcome[$2]
}
END {
    print score
}
