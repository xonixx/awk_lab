#!/usr/bin/awk -f
BEGIN {
  Tmp = ok("[ -d /dev/shm ]" ? "/dev/shm" : "/tmp")
  fhtagn()
}
function fhtagn(   file) {
  file = "1.tush" # TODO from input
}
function ok(cmd) { return system(cmd) == 0 }
