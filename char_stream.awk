BEGIN {
  test()
}

function test(   c) {
  while ((c=getChar())!="") {
    print "[" c "]"
    advance()
  }
}

function getChar(   c) {
  if (!CurrentLine) {
    PosInLine=1
    if ((getline CurrentLine) <= 0) {
      CurrentLine=""
      return
    }
  }
  c = 0 == PosInLine ? "\n" : substr(CurrentLine,PosInLine,1)
  if (!c) { # line ended
    if ((getline CurrentLine) <= 0) {
      CurrentLine=""
      return
    }
    PosInLine=0
    c = "\n"
  }
  return c
}

function advance() {
  PosInLine++
}