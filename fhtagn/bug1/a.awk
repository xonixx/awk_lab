#!/usr/bin/awk -f
BEGIN {
#  system("diff x.txt y.txt")
  print "yyy" | "diff x.txt -"
}