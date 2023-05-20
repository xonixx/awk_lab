#!/usr/bin/awk -f
BEGIN {
  Prog = "fhtagn"
  Tmp = ok("[ -d /dev/shm ]" ? "/dev/shm" : "/tmp")
  fhtagn()
  srand()
}
function fhtagn(   file,l,code,r,exitCode) {
  file = "1.tush" # TODO from input

  # 1. parse line-by-line

  while ((getline l) > 0) {
    if (l ~ /^\$/) {
      # 2. execute line starting '$', producing out & err & exit_code
      code = substr(l,2)
      r = rnd()
      stdOutF = Tmp "/" Prog "." r ".out"
      stdErrF = Tmp "/" Prog "." r ".err"
      code = "(" code ") 1>" stdOutF " 2>" stdErrF
      exitCode = system(code)
    }
  }

  # 3. parse result block (|@?)
  # 4. compile actual result block
  # 5. compare
  # 6. repeat from 1.
}
function rnd() { return int(2000000000 * rand()) }
function ok(cmd) { return system(cmd) == 0 }
