#!/usr/bin/env awk -f
{
    latest_prefix = length($0) - 13
    for (prefix = 1; prefix <= latest_prefix; ++prefix) {
        failed = 0
        for (i = prefix; (i < prefix + 13) && !failed; ++i) {
            if (index(substr($0,i+1,prefix+13-i), substr($0,i,1))) {
                failed = 1
                break
            }
        }
        if (!failed) {
            print prefix+13
            matched = 1
            break
        }
    }
    if (!matched) {
        print "PROCESSING ERROR"
        exit 1
    }
}
