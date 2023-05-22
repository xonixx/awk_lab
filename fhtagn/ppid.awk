BEGIN {
  "echo $PPID" | getline
  print $0
}