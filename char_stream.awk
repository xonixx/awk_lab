#
# depends on RS="\n" (default)
#
function getChar(   c) {
  if (!CurrentLine) {
    PosInLine=1
    if ((getline CurrentLine) <= 0) {
      CurrentLine=""
      return
    }
  }
  if (!(c = 0 == PosInLine ? "\n" : substr(CurrentLine,PosInLine,1))) { # line ended
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