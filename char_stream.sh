#!/bin/bash

#AWK=awk
AWK=./soft/bwk

echo '
aaa
bbbb ccccc
zzz
' | $AWK -f char_stream.awk -f char_stream_test.awk