#!/bin/bash

f="$1"

export PATH="$PATH:$MYDIR/soft/tush/bin"

if DIFF="diff --strip-trailing-cr" tush-check "$f"
then
  echo "TESTS PASSED : $f"
else
  echo >&2 "!!! TESTS FAILED !!! : $f"
  exit 1
fi