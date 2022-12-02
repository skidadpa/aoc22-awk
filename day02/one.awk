#!/usr/bin/env awk -f
BEGIN {
    shape["X"] = 1
    shape["Y"] = 2
    shape["Z"] = 3
    outcome["A X"] = 3
    outcome["A Y"] = 6
    outcome["A Z"] = 0
    outcome["B X"] = 0
    outcome["B Y"] = 3
    outcome["B Z"] = 6
    outcome["C X"] = 6
    outcome["C Y"] = 0
    outcome["C Z"] = 3
}
{
    score += shape[$2] + outcome[$0]
}
END {
    print score
}
