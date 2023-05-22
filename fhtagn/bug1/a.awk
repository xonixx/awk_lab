#!/usr/bin/awk -f
BEGIN {
#  system("diff x.txt y.txt")
  print "yyy" | (d = "diff -u x.txt -")
  close(d)
  exit 1
}