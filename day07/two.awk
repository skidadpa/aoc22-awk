#!/usr/bin/env awk -f
BEGIN {
    DS = "/"
    UP = ".."
}
/^\$ cd/ {
    if (NF != 3) {
        print "DATA ERROR"
        exit _exit=1
    }
    if (substr($3,1,1) == DS) {
        pwd = substr($3,2)
    } else if ($3 == UP) {
        sub(/\/?[^\/]*$/, "", pwd)
    } else {
        pwd = pwd DS $3
    }
    if (substr(pwd,length(pwd),1) == DS) {
        print "DATA ERROR"
        exit _exit=1
    }
    next
}
(NF != 2) {
    print "DATA ERROR"
    exit _exit=1
}
/^\$/ {
    if ($2 != "ls") {
        print "DATA ERROR"
        exit _exit=1
    }
    next
}
{
    DIRS[pwd][pwd DS $2] = 1
    if ($1 != "dir") {
        SIZES[pwd DS $2] = int($1)
    }
}
function compute_dir_size(top,  d, siz) {
    if (!(top in SIZES)) {
        siz = 0
        for (d in DIRS[top]) {
            if (!(d in SIZES)) {
                compute_dir_size(d)
            }
            siz += SIZES[d]
        }
        SIZES[top] = siz
    }
    DIR_SIZE[top] = SIZES[top]
}
END {
    if (_exit) {
        exit _exit
    }
    compute_dir_size("")
    used = DIR_SIZE[""]
    available = 70000000 - used
    required = 30000000 - available
    if ((available < 0) || (required <= 0)) {
        print "PROCESSING ERROR"
        exit _exit=1
    }
    smallest = used
    for (d in DIR_SIZE) {
        if (DIR_SIZE[d] >= required) {
            if (smallest > DIR_SIZE[d]) {
                smallest = DIR_SIZE[d]
            }
        }
    }
    print smallest
}
