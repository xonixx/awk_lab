#!/usr/bin/awk -f
# TODO catch include loops
# TODO implement "only once" include semantics
BEGIN {
  mglwnafh()
}
function mglwnafh(   i,file,includes,cmdLine,awk) {
  file = ARGV[1]
  delete includes
  parseIncludes(includes,file)
  #  for (i=0;i in includes;i++) printf "include[%d]=%s\n", i, includes[i]
  for (i = 0; i in includes; i++) cmdLine = cmdLine " -f " includes[i]
  #  print cmdLine
  if (!(awk = ENVIRON["AWK"])) awk = "awk"
  exit system(awk cmdLine)
}
function parseIncludes(includes, file,   err) {
  #  print "parseIncludes", file
  while ((err = getline < file) > 0 && /^#include/) {
    parseIncludes(includes, $2)
  }
  if (err < 0) {
    print "error: file not found: " file > "/dev/stderr"
    exit 1
  }
  includes[length(includes)] = file
  close(file)
}
