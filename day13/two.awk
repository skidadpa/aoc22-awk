#!/usr/bin/env awk -f
BEGIN {
    DEBUG = 0
}
function split_list(str,   i) {
    if (str !~ /^\[.*\]$/) {
        print "DATA ERROR"
        exit _exit=1
    }
}
function parse_item(str,   i, depth) {
    depth = 0
    for (i=1; i <= length(str); ++i) {
        ch = substr(str, i, 1)
        if (ch == "[") {
            ++depth
        } else if (ch == "]") {
            if (depth == 0) {
                return substr(str, 1, i - 1)
            }
            --depth
            if (depth == 0) {
                return substr(str, 1, i)
            }
        } else if (ch == ",") {
            if (depth == 0) {
                return substr(str, 1, i - 1)
            }
        }
    }
}
function check_pair(left, right,   left_is_number, right_is_number, left_len, il, ir, left_sublist, right_sublist, sub_result) {
    # print "checking", left, right
    left_is_number = (left !~ /^\[/)
    right_is_number = (right !~ /^\[/)
    if (left_is_number && right_is_number) {
        # print "numeric compare"
        return 0 + right - left
    }
    if (left_is_number) {
        left = "[" left "]"
    }
    if (right_is_number) {
        right = "[" right "]"
    }
    il = ir = 2
    while (il <= length(left)) {
        if (substr(left,il,1) == "]") {
            if (substr(right,ir,1) == "]") {
                return 0
            }
            return 1
        }
        if (substr(right,ir,1) == "]") {
            return -1
        }
        left_sublist = parse_item(substr(left, il))
        right_sublist = parse_item(substr(right, ir))
        sub_result = check_pair(left_sublist, right_sublist)
        if (sub_result != 0) {
            return sub_result
        }
        il += length(left_sublist)
        ir += length(right_sublist)
        if (substr(left,il,1) == ",") {
            ++il
        }
        if (substr(right,ir,1) == ",") {
            ++ir
        }
        # printf("{%s} {%s} left\n", substr(left,il), substr(right,ir))
    }
    print "PROCESSING ERROR"
    exit _exit=1
}
function compare_pair(i1, v1, i2, v2) {
    return -check_pair(v1, v2)
}
(NF == 0) { next }
{
    packet[++npackets] = $0
}
END {
    if (_exit) {
        exit _exit
    }
    packet[++npackets] = "[[2]]"
    packet[++npackets] = "[[6]]"
    if (DEBUG) {
        for (p in packet) {
            print packet[p]
        }
        print "---"
    }
    asort(packet, sorted_packets, "compare_pair")
    for (p in sorted_packets) {
        if (DEBUG) {
            print sorted_packets[p]
        }
        if (sorted_packets[p] == "[[2]]") {
            divider_1_index = p;
            if (DEBUG) {
                print "DIVIDER 1 INDEX =", p
            }
        } else if (sorted_packets[p] == "[[6]]") {
            divider_2_index = p;
            if (DEBUG) {
                print "DIVIDER 2 INDEX =", p
            }
        }
    }
    print divider_1_index * divider_2_index
}
