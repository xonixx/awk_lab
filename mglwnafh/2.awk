#include 3.awk
#include 4.awk

BEGIN { print "BEGIN 2.awk" }

function f2() {
  print "f2"
  return 77
}