#!/bin/sh
${AWK:-awk} -f nat_sort.awk -f ungron.awk "$@"