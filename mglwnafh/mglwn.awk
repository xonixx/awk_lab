#!/usr/bin/awk -f
# TODO catch include loops
BEGIN {
  mglwnafh()
}
function mglwnafh(   i,file,includes) {
  file = ARGV[1]
  delete includes
  parseIncludes(includes,file)
  #  for (i=0;i in includes;i++) printf "include[%d]=%s\n", i, includes[i]
  for (i=0;i in includes;i++) cmdLine = "-f " includes[i] " " cmdLine
  print cmdLine
}
function parseIncludes(includes, file) {
#  print "parseIncludes ", file
  includes[length(includes)] = file
  while (getline < file && /^#include/) {
    parseIncludes(includes, $2)
  }
  close(file)
}