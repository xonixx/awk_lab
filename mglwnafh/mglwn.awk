#!/usr/bin/awk -f
BEGIN {
  mglwnafh()
}
function mglwnafh() {
  file = ARGV[1]
  delete includes
  parseIncludes(includes,file)
  for (i=0;i in includes;i++) printf "include[%d]=%s\n", i, includes[i]
}
function parseIncludes(includes, file) {
  includes[length(includes)]=file
  while(getline < file && /^#include/) {
    parseIncludes(includes, $2)
  }
  close(file)
}