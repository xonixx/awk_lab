#!/usr/bin/awk -f
BEGIN {
  system("( ./a.awk ) 1>out.txt 2>err.txt")
  system("ls -l out.txt err.txt")
  system("cat out.txt")
  system("rm out.txt err.txt")
}