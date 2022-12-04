#!/usr/bin/env awk -f
BEGIN {
    FS="[-,]"
    count = 0
}
{
    if (int($1) > int($2) || int($3) > int($4)) {
        print "DATA ERROR"
        exit _exit=1
    }
    if ((int($1) <= int($4)) && (int($2) >= int($3))) {
        ++count
    }
}
END {
     if (_exit) {
        exit _exit
    }
    print count
}
