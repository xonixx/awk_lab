BEGIN {
  CurrentLine=""
  Consumed=0
  PosInLine=1

  test()
}

function test(   c) {
  do {
    c=getChar()
    print c
    advance()
  } while (""!=c)
}

function getChar(   c) {
  if (!CurrentLine) {
    if ((getline CurrentLine) <= 0)
      return
  }
  c = substr(CurrentLine,PosInLine,1)
  if (!c) { # line ended
    # TODO line separator
    if ((getline CurrentLine) <= 0)
      return
    PosInLine=1
    c = substr(CurrentLine,PosInLine,1)
  }
  return c
}

function advance() {
  PosInLine++
}

function unshift(c) {

}