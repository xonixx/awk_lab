#!/usr/bin/awk -f
BEGIN {
  Prog = "fhtagn"
  Tmp = ok("[ -d /dev/shm ]" ? "/dev/shm" : "/tmp")
  fhtagn()
  srand()
}
function fhtagn(   file,l,code,r,exitCode,stdOutF,stdErrF,testStarted,expected) {
  file = "1.tush" # TODO from input

  # 1. parse line-by-line

  while ((getline l < file) > 0) {
    if (l ~ /^\$/) {
      if (testStarted) {
        testStarted = 0
        checkTestResult(expected,stdOutF,stdErrF,exitCode)
      } else {
        testStarted = 1
        expected = ""
      }
      # 2. execute line starting '$', producing out & err & exit_code
      code = substr(l,2)
      r = rnd()
      stdOutF = Tmp "/" Prog "." r ".out"
      stdErrF = Tmp "/" Prog "." r ".err"
      code = "(" code ") 1>" stdOutF " 2>" stdErrF
      exitCode = system(code)
    } else if (l ~ /^[|@?]/) {
      # 3. parse result block (|@?)
      expected = expected l "\n"
    } else {
      if (testStarted) {
        testStarted = 0
        checkTestResult(expected,stdOutF,stdErrF,exitCode)
      }
    }
  }
  close(file)
  if (testStarted) {
    checkTestResult(expected,stdOutF,stdErrF,exitCode)
  }

  # 4. compile actual result block
  # 5. compare
  # 6. repeat from 1.
}
function checkTestResult(expected, stdOutF, stdErrF, exitCode,   actual) {
  actual = prefixFile("|",stdOutF) prefixFile("@",stdErrF)
  if (exitCode != 0) actual = actual "? " exitCode
  if (expected != actual) {
    # TODO diff
    printf "FAIL: \n expected:\n%s\n\nactual:\n%s", expected, actual
  }
}
function prefixFile(prefix, fname,   l,res) {
  while ((getline l < fname) > 0) {
    res = res prefix " " l "\n"
  }
  close(fname)
  return res
}
function rnd() { return int(2000000000 * rand()) }
function ok(cmd) { return system(cmd) == 0 }
